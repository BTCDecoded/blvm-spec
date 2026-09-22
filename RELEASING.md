# Releasing the Orange Paper (`blvm-spec`)

## Version convention

A named release of the Orange Paper is a **git tag on this repository** following semver: `v<MAJOR>.<MINOR>.<PATCH>` (e.g. `v1.0.0`).

| Build context | Version string | SHA |
|---------------|---------------|-----|
| Tagged release | `v1.2.0` (the tag name) | full commit SHA |
| `main` push (dev) | `0.0.0-dev+<shortsha>` or `git describe --tags --always --dirty` | full commit SHA |

Do **not** hand-edit `**Version X.Y**` in the markdown banner for routine prose commits; that line reflects the **specification edition** (major/minor), not every incremental commit.

## What triggers the build chain

Any push to `main` or a published **release** fires [`trigger-chain.yml`](.github/workflows/trigger-chain.yml), which dispatches `blvm-consensus` (and other consumers) with the payload:

```json
{
  "triggered_by": "blvm-spec",
  "version":      "<tag or branch name>",
  "source_ref":   "<git ref>",
  "source_sha":   "<full commit SHA>",
  "content_sha256": "<sha256 of PROTOCOL.md+ARCHITECTURE.md+THE_ORANGE_PAPER.md>"
}
```

Consumers **must** record `source_sha` (and `content_sha256` when present) in their build metadata and release artifacts so any build can be traced back to the exact spec revision it was verified against.

## How to cut a release

1. Ensure `main` is green (all CI jobs pass, including `check-toc` and `check-spec-lock-ids`).
2. Decide on the semver bump:
   - **Patch** — wording clarifications, typo fixes, notation alignment; no new sections or removed theorems.
   - **Minor** — new sections, new theorems, extended coverage; backward-compatible with existing `#[spec_locked]` IDs.
   - **Major** — section renumbering, removed or replaced theorems, breaking changes to IDs that `#[spec_locked]` in downstream crates reference.
3. Create and push the tag:
   ```bash
   git tag -a v1.0.0 -m "Orange Paper v1.0.0"
   git push origin v1.0.0
   ```
4. Create a **GitHub Release** from the tag (triggers the full dispatch chain automatically).
5. Update the `**Version X.Y**` banner in `PROTOCOL.md` and `THE_ORANGE_PAPER.md` **only** on major or minor bumps (not patches).

## `SPEC_META.json`

`SPEC_META.json` at the repo root is **generated automatically** by CI (via `scripts/spec-meta.mjs`) on every push to `main` and on release. Do **not** edit it by hand. Pull requests fail when `content_sha256` does not match `PROTOCOL.md`, `ARCHITECTURE.md`, and `THE_ORANGE_PAPER.md`. The git snapshot fields (`sha`, `git_describe`, `version`, `ref`) are refreshed by that main-branch job; they name the commit the generator ran on, not the commit that contains this file.

To regenerate locally before pushing:
```bash
node scripts/spec-meta.mjs
```

This requires Node.js ≥ 18 and a git checkout (the script reads `git describe` output).
