#!/usr/bin/env python3
"""Require Conventional Commits on pull requests.

Subjects must match:

    type(scope): description

`type` is feat, fix, docs, style, refactor, perf, test, build, ci, chore, or
revert. `scope` is optional. Existing release automation subjects are still
accepted: `Bump version to ...`, `Release ...`, and `Merge ...`.

A commit that touches a path in `.github/freeze-paths.txt` must also carry a
body line `Consensus: yes` or `Consensus: no`.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONVENTIONAL = re.compile(
    r"^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)"
    r"(\([a-z0-9._-]+\))?!?: [^ ].+"
)
GRANDFATHERED = re.compile(r"^(Bump version to |Release |Merge )")
CONSENSUS = re.compile(r"^Consensus: (yes|no)\s*$", re.MULTILINE)


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True)


def prefixes() -> list[str]:
    path = ROOT / ".github" / "freeze-paths.txt"
    if not path.exists():
        return []
    found = []
    for line in path.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            found.append(line)
    return found


def frozen(path: str, frozen_prefixes: list[str]) -> bool:
    for prefix in frozen_prefixes:
        if prefix.endswith("/") and path.startswith(prefix):
            return True
        if path == prefix:
            return True
    return False


def main() -> int:
    base = os.environ.get("BASE_REF", "main")
    ref = f"origin/{base}"
    try:
        git("rev-parse", "--verify", ref)
    except subprocess.CalledProcessError:
        subprocess.check_call(["git", "fetch", "origin", base], cwd=ROOT)
    commits = [line for line in git("rev-list", "--reverse", f"{ref}..HEAD").splitlines() if line]
    frozen_prefixes = prefixes()
    failed = False
    if not commits:
        print("commit convention: no commits in the pull request range")
        return 0
    for sha in commits:
        message = git("log", "-1", "--format=%B", sha)
        subject = message.splitlines()[0] if message.splitlines() else ""
        if CONVENTIONAL.match(subject) or GRANDFATHERED.match(subject):
            pass
        else:
            print(f"{sha[:12]} subject is not a Conventional Commit: {subject}")
            failed = True
            continue
        names = git("diff-tree", "--no-commit-id", "--name-only", "-r", sha).splitlines()
        if any(frozen(name, frozen_prefixes) for name in names) and not CONSENSUS.search(message):
            print(f"{sha[:12]} touches a frozen path and needs a `Consensus: yes` or `Consensus: no` line")
            failed = True
    if failed:
        return 1
    print(f"commit convention: {len(commits)} commit(s) accepted")
    return 0


if __name__ == "__main__":
    sys.exit(main())
