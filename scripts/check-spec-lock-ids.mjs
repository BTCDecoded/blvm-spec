#!/usr/bin/env node
/**
 * Ensures #[spec_locked("x.y")] / cfg_attr(..., spec_locked("x.y")) IDs in
 * blvm-consensus, blvm-protocol, blvm-node exist as headings in
 * PROTOCOL.md + ARCHITECTURE.md.
 *
 * Heading rule matches blvm-spec-lock: ^#{2,6}\s+(\d+(?:\.\d+)*)\s+
 *
 * Usage: node blvm-spec/scripts/check-spec-lock-ids.mjs
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SPEC_ROOT = path.join(__dirname, "..");
const ROOT = path.resolve(SPEC_ROOT, "..");

const HEADING_RE = /^(#{2,6})\s+(\d+(?:\.\d+)*)\s+.+$/;
const LOCK_RE = /spec_locked\s*\(\s*"([0-9.]+)"/g;

function sectionIdsFromMd(filePath) {
  const ids = new Set();
  const text = fs.readFileSync(filePath, "utf8");
  for (const line of text.split(/\r?\n/)) {
    const m = line.match(HEADING_RE);
    if (m) ids.add(m[2]);
  }
  return ids;
}

function collectSpecIds() {
  const a = sectionIdsFromMd(path.join(SPEC_ROOT, "PROTOCOL.md"));
  const b = sectionIdsFromMd(path.join(SPEC_ROOT, "ARCHITECTURE.md"));
  return new Set([...a, ...b]);
}

function* walkRsFiles(dir) {
  if (!fs.existsSync(dir)) return;
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) yield* walkRsFiles(p);
    else if (ent.isFile() && ent.name.endsWith(".rs")) yield p;
  }
}

function specLockedIdsInFile(filePath) {
  const text = fs.readFileSync(filePath, "utf8");
  const ids = [];
  let m;
  LOCK_RE.lastIndex = 0;
  while ((m = LOCK_RE.exec(text)) !== null) ids.push(m[1]);
  return ids;
}

const specIds = collectSpecIds();
const crates = [
  path.join(ROOT, "blvm-consensus/src"),
  path.join(ROOT, "blvm-protocol/src"),
  path.join(ROOT, "blvm-node/src"),
];

const missing = new Map(); // id -> Set of relative file paths
const allUsed = new Set();

for (const crateSrc of crates) {
  for (const file of walkRsFiles(crateSrc)) {
    for (const id of specLockedIdsInFile(file)) {
      allUsed.add(id);
      if (!specIds.has(id)) {
        if (!missing.has(id)) missing.set(id, new Set());
        missing.get(id).add(path.relative(ROOT, file));
      }
    }
  }
}

if (missing.size === 0) {
  console.log(
    `check-spec-lock-ids: OK — ${allUsed.size} distinct IDs used in Rust all have headings in PROTOCOL+ARCHITECTURE.`
  );
  process.exit(0);
}

console.error("check-spec-lock-ids: MISSING headings for these spec_locked IDs:\n");
for (const [id, files] of [...missing.entries()].sort((a, b) =>
  a[0].localeCompare(b[0], undefined, { numeric: true })
)) {
  console.error(`  ${id}`);
  for (const f of [...files].sort()) console.error(`      ${f}`);
}
process.exit(1);
