#!/usr/bin/env python3
"""Minimal RFC 5804 ManageSieve client for deterministic Sieve deployment.

Uses STARTTLS, verifies the server certificate, authenticates with SASL PLAIN,
uploads a script, activates it, lists scripts, logs out, and emits JSON evidence.
Secrets are never written to output.
"""
from __future__ import annotations

import argparse
import base64
import json
import socket
import ssl
import sys
from pathlib import Path

TERMINALS = (b"OK", b"NO", b"BYE")


class ManageSieveError(RuntimeError):
    pass


class Client:
    def __init__(self, host: str, port: int, timeout: float) -> None:
        self.host = host
        self.port = port
        self.timeout = timeout
        self.sock: socket.socket | ssl.SSLSocket | None = None
        self.file = None
        self.transcript: list[str] = []

    def connect(self) -> None:
        self.sock = socket.create_connection((self.host, self.port), timeout=self.timeout)
        self.file = self.sock.makefile("rwb", buffering=0)
        self._read_response("greeting")
        self._send_line(b"STARTTLS")
        self._require_ok(self._read_response("starttls"), "STARTTLS")

        context = ssl.create_default_context()
        self.sock = context.wrap_socket(self.sock, server_hostname=self.host)
        self.file = self.sock.makefile("rwb", buffering=0)
        self._read_response("post_tls_capabilities")

    def authenticate_plain(self, username: str, password: str) -> None:
        payload = base64.b64encode(("\0" + username + "\0" + password).encode("utf-8"))
        command = b'AUTHENTICATE "PLAIN" "' + payload + b'"'
        self._send_line(command, redact=True)
        self._require_ok(self._read_response("authenticate"), "AUTHENTICATE")

    def put_script(self, name: str, content: bytes) -> None:
        prefix = f'PUTSCRIPT "{quote(name)}" {{{len(content)}+}}'.encode("utf-8")
        self._send_line(prefix)
        assert self.file is not None
        self.file.write(content + b"\r\n")
        self.transcript.append(f"C: <script bytes={len(content)}>")
        self._require_ok(self._read_response("putscript"), "PUTSCRIPT")

    def set_active(self, name: str) -> None:
        self._send_line(f'SETACTIVE "{quote(name)}"'.encode("utf-8"))
        self._require_ok(self._read_response("setactive"), "SETACTIVE")

    def list_scripts(self) -> list[str]:
        self._send_line(b"LISTSCRIPTS")
        lines = self._read_response("listscripts")
        self._require_ok(lines, "LISTSCRIPTS")
        return [line.decode("utf-8", "replace") for line in lines]

    def logout(self) -> None:
        try:
            if self.file is not None:
                self._send_line(b"LOGOUT")
                self._read_response("logout")
        finally:
            if self.file is not None:
                self.file.close()
            if self.sock is not None:
                self.sock.close()

    def _send_line(self, line: bytes, redact: bool = False) -> None:
        assert self.file is not None
        self.file.write(line + b"\r\n")
        self.transcript.append("C: <redacted AUTHENTICATE>" if redact else "C: " + line.decode("utf-8", "replace"))

    def _read_response(self, stage: str) -> list[bytes]:
        assert self.file is not None
        lines: list[bytes] = []
        while True:
            raw = self.file.readline()
            if not raw:
                raise ManageSieveError(f"connection closed during {stage}")
            line = raw.rstrip(b"\r\n")
            lines.append(line)
            self.transcript.append("S: " + line.decode("utf-8", "replace"))
            if line.upper().startswith(TERMINALS):
                return lines

    @staticmethod
    def _require_ok(lines: list[bytes], command: str) -> None:
        if not lines or not lines[-1].upper().startswith(b"OK"):
            rendered = " | ".join(x.decode("utf-8", "replace") for x in lines)
            raise ManageSieveError(f"{command} failed: {rendered}")


def quote(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="imap.migadu.com")
    parser.add_argument("--port", type=int, default=4190)
    parser.add_argument("--user", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--script", required=True, type=Path)
    parser.add_argument("--name", default="t4h-github-agent-routing")
    parser.add_argument("--timeout", type=float, default=30.0)
    parser.add_argument("--receipt", required=True, type=Path)
    args = parser.parse_args()

    content = args.script.read_bytes()
    client = Client(args.host, args.port, args.timeout)
    state = "BLOCKED"
    error = ""
    scripts: list[str] = []
    authenticated = False
    uploaded = False
    active = False
    logout_attempted = False

    try:
        client.connect()
        client.authenticate_plain(args.user, args.password)
        authenticated = True
        client.put_script(args.name, content)
        uploaded = True
        client.set_active(args.name)
        scripts = client.list_scripts()
        active = any(args.name in line and "ACTIVE" in line.upper() for line in scripts)
        if not active:
            raise ManageSieveError("LISTSCRIPTS did not confirm active script")
        state = "REAL"
    except Exception as exc:
        error = f"{type(exc).__name__}: {exc}"
    finally:
        logout_attempted = True
        try:
            client.logout()
        except Exception as exc:
            if not error:
                error = f"logout: {type(exc).__name__}: {exc}"

    args.receipt.parent.mkdir(parents=True, exist_ok=True)
    receipt = {
        "schema_version": "t4h.managesieve-deployment.v1",
        "state": state,
        "host": args.host,
        "port": args.port,
        "user": args.user,
        "script_name": args.name,
        "script_bytes": len(content),
        "listscripts": scripts,
        "authenticated": authenticated,
        "uploaded": uploaded,
        "active": active,
        "logout_attempted": logout_attempted,
        "error": error,
        "transcript": client.transcript,
    }
    args.receipt.write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps(receipt, indent=2))
    return 0 if state == "REAL" else 1


if __name__ == "__main__":
    sys.exit(main())
