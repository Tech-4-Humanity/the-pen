from pathlib import Path

import pytest

from runtime_operator.core import RuntimeFailure, classify_bucket, find_repo, require_safe_public_source, sha256


def test_find_repo_from_nested_directory(tmp_path: Path) -> None:
    repo = tmp_path / "the-pen"
    nested = repo / "a" / "b"
    nested.mkdir(parents=True)
    (repo / ".git").mkdir()
    assert find_repo(nested) == repo


def test_sha256_is_deterministic(tmp_path: Path) -> None:
    path = tmp_path / "x.txt"
    path.write_bytes(b"runtime-proof")
    assert sha256(path) == "15ef21b5086776f4b7fe28d43b47f6a84a96e8e43441f4657a8e9eae17b31fb4"


def test_bucket_classification() -> None:
    assert classify_bucket("t4h-archive-123") == "PRIVATE_ARCHIVE"
    assert classify_bucket("my-public-website") == "PUBLIC_WEBSITE"
    assert classify_bucket("misc-data") == "UNCLASSIFIED"


def test_public_deploy_blocks_private_evidence(tmp_path: Path) -> None:
    (tmp_path / "bank.csv").write_text("private", encoding="utf-8")
    with pytest.raises(RuntimeFailure):
        require_safe_public_source(tmp_path, "PUBLIC_WEBSITE")


def test_private_archive_accepts_evidence(tmp_path: Path) -> None:
    (tmp_path / "bank.csv").write_text("private", encoding="utf-8")
    require_safe_public_source(tmp_path, "PRIVATE_ARCHIVE")
