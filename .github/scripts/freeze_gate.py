#!/usr/bin/env python3
"""Fail a pull request that touches frozen paths without an explicit marker.

The marker is the label `freeze-exception` or a pull-request body line
`Freeze-Exception: <bugfix+test|docs|tests|refactor-with-proof>`.
The marker does not waive review. It records that the change is one of the
kinds the freeze allows.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True)


def frozen_prefixes() -> list[str]:
    path = ROOT / ".github" / "freeze-paths.txt"
    prefixes = []
    for line in path.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            prefixes.append(line)
    return prefixes


def is_frozen(name: str, prefixes: list[str]) -> bool:
    for prefix in prefixes:
        if prefix.endswith("/"):
            if name.startswith(prefix):
                return True
        elif name == prefix:
            return True
    return False


def ensure_base(base: str) -> str:
    ref = f"origin/{base}"
    try:
        git("rev-parse", "--verify", ref)
        return ref
    except subprocess.CalledProcessError:
        subprocess.check_call(["git", "fetch", "origin", base], cwd=ROOT)
        git("rev-parse", "--verify", ref)
        return ref


def main() -> int:
    base = os.environ.get("BASE_REF", "main")
    ref = ensure_base(base)
    changed = [line for line in git("diff", "--name-only", f"{ref}...HEAD").splitlines() if line]
    prefixes = frozen_prefixes()
    frozen = [name for name in changed if is_frozen(name, prefixes)]
    if not frozen:
        print("freeze gate: no frozen paths changed")
        return 0
    labels = {part.strip() for part in os.environ.get("PR_LABELS", "").split(",") if part.strip()}
    body = os.environ.get("PR_BODY") or ""
    marked = "freeze-exception" in labels or "Freeze-Exception:" in body
    print("frozen files:")
    for name in frozen:
        print(f"  {name}")
    if not marked:
        print("This pull request changes frozen paths.")
        print("Add the label freeze-exception, or a body line of the form:")
        print("Freeze-Exception: bugfix+test | docs | tests | refactor-with-proof")
        return 1
    if "Freeze-Exception:" in body:
        line = next(item for item in body.splitlines() if "Freeze-Exception:" in item)
        reason = line.split("Freeze-Exception:", 1)[1].strip().lower()
        allowed = ("bugfix+test", "docs", "tests", "refactor-with-proof")
        if not any(reason.startswith(item) for item in allowed):
            print(f"Freeze-Exception reason must start with one of: {', '.join(allowed)}")
            return 1
    print("freeze gate: marker present")
    return 0


if __name__ == "__main__":
    sys.exit(main())
