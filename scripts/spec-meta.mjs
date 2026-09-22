#!/usr/bin/env node
/**
 * Generates SPEC_META.json at the blvm-spec repo root.
 *
 * Fields:
 *   version         – semver tag if HEAD is tagged, else "0.0.0-dev+<shortsha>"
 *   git_describe    – output of `git describe --tags --always`
 *                     (`--dirty` is omitted: a dirty worktree is not a snapshot)
 *   sha             – full HEAD commit SHA
 *   ref             – current branch or tag ref (e.g. "main", "v1.0.0")
 *   content_sha256  – SHA-256 over the concatenated bytes of the canonical spec files
 *                     (PROTOCOL.md + ARCHITECTURE.md + THE_ORANGE_PAPER.md, in that order,
 *                      only including files that exist)
 *   generated_at    – ISO-8601 UTC timestamp
 *
 * Usage:
 *   node scripts/spec-meta.mjs            # writes SPEC_META.json
 *   node scripts/spec-meta.mjs --verify   # exits non-zero if SPEC_META.json is stale
 */

import { createHash } from "crypto";
import { execSync } from "child_process";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = join(__dirname, "..");
const OUTPUT_PATH = join(REPO_ROOT, "SPEC_META.json");

const VERIFY_MODE = process.argv.includes("--verify");

// ---------------------------------------------------------------------------
// Git helpers
// ---------------------------------------------------------------------------

function git(cmd) {
  try {
    return execSync(`git -C ${JSON.stringify(REPO_ROOT)} ${cmd}`, {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
  } catch {
    return "";
  }
}

function resolveVersion() {
  // Check if HEAD is exactly on a tag
  const exactTag = git("describe --tags --exact-match HEAD 2>/dev/null");
  if (exactTag && /^v\d+\.\d+\.\d+/.test(exactTag)) {
    return exactTag.replace(/^v/, ""); // strip leading v for semver field
  }
  // Fall back to short sha
  const shortSha = git("rev-parse --short HEAD");
  return shortSha ? `0.0.0-dev+${shortSha}` : "0.0.0-dev";
}

function resolveRef() {
  // Prefer tag name if HEAD is tagged
  const tag = git("describe --tags --exact-match HEAD 2>/dev/null");
  if (tag) return tag;
  // Otherwise symbolic ref (branch name)
  const branch = git("rev-parse --abbrev-ref HEAD");
  return branch || "unknown";
}

// ---------------------------------------------------------------------------
// Content hash over canonical spec files
// ---------------------------------------------------------------------------

const CANONICAL_FILES = [
  "PROTOCOL.md",
  "ARCHITECTURE.md",
  "THE_ORANGE_PAPER.md",
];

function computeContentHash() {
  const hash = createHash("sha256");
  let anyFound = false;
  for (const name of CANONICAL_FILES) {
    const p = join(REPO_ROOT, name);
    if (existsSync(p)) {
      hash.update(readFileSync(p));
      anyFound = true;
    }
  }
  return anyFound ? hash.digest("hex") : null;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

const sha = git("rev-parse HEAD");
const gitDescribe = git("describe --tags --always");

const meta = {
  version: resolveVersion(),
  git_describe: gitDescribe || sha.slice(0, 12),
  sha,
  ref: resolveRef(),
  content_sha256: computeContentHash(),
  generated_at: new Date().toISOString(),
};

const output = JSON.stringify(meta, null, 2) + "\n";

if (VERIFY_MODE) {
  if (!existsSync(OUTPUT_PATH)) {
    console.error(
      "SPEC_META.json does not exist. Run: node scripts/spec-meta.mjs"
    );
    process.exit(1);
  }
  const existing = readFileSync(OUTPUT_PATH, "utf8");
  const existingParsed = JSON.parse(existing);
  // The content hash is the spec bytes. version, sha, git_describe, and ref
  // name the commit the generator ran on, which is the parent of the
  // `[skip ci]` meta commit, so they do not equal HEAD when this file is read.
  const STABLE = ["content_sha256"];
  let drift = false;
  for (const key of STABLE) {
    if (existingParsed[key] !== meta[key]) {
      console.error(
        `SPEC_META.json is stale: field "${key}" is "${existingParsed[key]}", expected "${meta[key]}".`
      );
      drift = true;
    }
  }
  if (drift) {
    console.error("Run: node scripts/spec-meta.mjs  (then commit the result)");
    process.exit(1);
  }
  console.log("SPEC_META.json is up to date.");
} else {
  writeFileSync(OUTPUT_PATH, output, "utf8");
  console.log(`Wrote SPEC_META.json (sha=${meta.sha.slice(0, 12)}, version=${meta.version})`);
}
