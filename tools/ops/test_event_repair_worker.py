#!/usr/bin/env python3
"""Dependency-free regression tests for the event repair worker."""

import importlib.util
import pathlib
import subprocess
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location("event_repair_worker", HERE / "event_repair_worker.py")
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def test_colon_scalar_repair():
    broken = '''name: Broken\njobs:\n  test:\n    runs-on: ubuntu-latest\n    steps:\n      - name: Empty\n        run: echo "PEN Ingest: Empty inbox - no work to do"\n'''
    repaired, changed = MODULE.repair_plain_scalars(broken)
    assert changed
    assert 'run: "echo \\"PEN Ingest: Empty inbox - no work to do\\""' in repaired

    with tempfile.NamedTemporaryFile("w", suffix=".yml", delete=False) as f:
        f.write(repaired)
        path = pathlib.Path(f.name)
    try:
        result = subprocess.run(
            ["ruby", "-e", "require 'yaml'; YAML.load_file(ARGV[0]);", str(path)],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, result.stderr
    finally:
        path.unlink(missing_ok=True)


def test_safe_lines_are_unchanged():
    valid = "name: Example\nrun: echo hello\nuses: actions/checkout@v4\n"
    repaired, changed = MODULE.repair_plain_scalars(valid)
    assert not changed
    assert repaired == valid


if __name__ == "__main__":
    test_colon_scalar_repair()
    test_safe_lines_are_unchanged()
    print("PASS: event repair worker regression tests")
