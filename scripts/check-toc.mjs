#!/usr/bin/env node
/**
 * Verifies markdown links in PROTOCOL.md:
 * 1) Table of Contents: #fragment → PROTOCOL heading; ./ARCHITECTURE.md# → ARCHITECTURE heading.
 * 2) Rest of PROTOCOL (outside fenced ``` blocks): same rules for (#fragment) and ARCHITECTURE.md#.
 *
 * Skips: http(s)://, mailto:, bare paths without #.
 *
 * Usage (from blvm-spec/): node scripts/check-toc.mjs
 * Exit 1 on any mismatch (for CI).
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const PROTOCOL_PATH = path.join(ROOT, "PROTOCOL.md");
const ARCH_PATH = path.join(ROOT, "ARCHITECTURE.md");

/** GitHub-style slug: lowercase, non-word punctuation removed, `_` kept, whitespace → `-`. */
function slugify(text) {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, "")
    .trim()
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "");
}

function headingSlugs(md) {
  const slugs = new Set();
  for (const line of md.split(/\r?\n/)) {
    const m = line.match(/^(#{2,6})\s+(.+)$/);
    if (!m) continue;
    const title = m[2].trim();
    if (title.startsWith("Table of Contents")) continue;
    slugs.add(slugify(title));
  }
  return slugs;
}

function extractTocBlock(md) {
  const start = md.indexOf("## Table of Contents");
  if (start === -1) throw new Error("No ## Table of Contents");
  const end = md.indexOf("\n## 1. Introduction", start);
  if (end === -1) throw new Error("No ## 1. Introduction after TOC");
  return md.slice(start, end);
}

/**
 * @param {string} md
 * @param {(target: string, context: string) => void} onLink - context = line text for errors
 */
function forEachMarkdownLinkOutsideFences(md, onLink) {
  let inFence = false;
  for (const line of md.split(/\r?\n/)) {
    const t = line.trim();
    if (t.startsWith("```")) inFence = !inFence;
    if (inFence) continue;
    const linkRe = /\]\(([^)]+)\)/g;
    let m;
    while ((m = linkRe.exec(line)) !== null) {
      onLink(m[1].trim(), line);
    }
  }
}

function validateTarget(target, protocolSlugs, archSlugs, errors, label) {
  if (!target || target.startsWith("http") || target.startsWith("mailto:")) return;
  const hashIdx = target.indexOf("#");
  if (hashIdx === -1) return;
  const pathPart = target.slice(0, hashIdx);
  const frag = target.slice(hashIdx + 1);
  if (!frag) {
    errors.push(`${label}: empty fragment in (${target})`);
    return;
  }
  if (pathPart === "" || pathPart === "#") {
    if (!protocolSlugs.has(frag)) {
      errors.push(`${label}: PROTOCOL has no heading for #${frag}`);
    }
  } else if (pathPart === "./ARCHITECTURE.md" || pathPart === "ARCHITECTURE.md") {
    if (!archSlugs.has(frag)) {
      errors.push(`${label}: ARCHITECTURE.md has no heading for #${frag} (from ${target})`);
    }
  } else {
    errors.push(`${label}: unsupported path ${pathPart} in (${target})`);
  }
}

function main() {
  const protocol = fs.readFileSync(PROTOCOL_PATH, "utf8");
  const arch = fs.readFileSync(ARCH_PATH, "utf8");
  const protocolSlugs = headingSlugs(protocol);
  const archSlugs = headingSlugs(arch);
  const errors = [];

  const toc = extractTocBlock(protocol);
  let m;
  const tocLinkRe = /\]\(([^)]+)\)/g;
  while ((m = tocLinkRe.exec(toc)) !== null) {
    validateTarget(m[1].trim(), protocolSlugs, archSlugs, errors, "TOC");
  }

  forEachMarkdownLinkOutsideFences(protocol, (target, line) => {
    validateTarget(target, protocolSlugs, archSlugs, errors, `body: ${line.slice(0, 72)}…`);
  });

  if (errors.length) {
    console.error("check-toc: failures:\n" + errors.map((e) => "  - " + e).join("\n"));
    process.exit(1);
  }
  console.log("check-toc: OK (TOC + in-body # / ARCHITECTURE.md# links).");
}

main();
