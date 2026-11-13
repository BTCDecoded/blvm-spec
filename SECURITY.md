# Security policy

BLVM validates Bitcoin. A consensus bug, a remote crash, and a memory-safety bug are the reports we want first.

## Report in private

Do not open a public GitHub issue for a vulnerability.

1. GitHub private vulnerability reporting on the repository that contains the bug: `https://github.com/BTCDecoded/<repo>/security/advisories/new`.
2. Email `security@thebitcoincommons.org`.

The encrypted channel is that mailbox. A published key is **not on file yet**. Until a maintainer publishes a fingerprint in this file, email is unencrypted and GitHub private reporting is the channel that keeps the report off the public issue tracker. Do not send a live mainnet exploit to a public list while the key is missing.

Include what you can: the crate, the commit, the network, whether you think it splits the chain or only crashes one process, and a minimal reproduction. A patch is welcome and not required.

## Scope

In scope:

- Consensus and validation in `blvm-consensus`, `blvm-spec`, `blvm-spec-lock`, and the frozen paths in `blvm-protocol` and `blvm-node`.
- Remote crash, denial of service, and memory safety in the node, the RPC server, and the P2P stack.
- Authentication bypass on RPC.
- Chainstate corruption after a crash or a reorg.

Out of scope:

- A third-party module you installed yourself, unless the node failed to confine it.
- Social engineering of operators.
- Issues that require a local account and do not cross into chainstate or keys, unless they are memory safety.

The node does not custody keys in the default build. Wallet-key bugs in a separate module are in scope for that module's repository and out of scope for consensus.

## Response targets

These are targets, not a claim about past performance. The advisory record is the evidence.

| Step | Target |
| --- | --- |
| Acknowledgement | 2 days |
| Triage, with a severity label | 7 days |
| Fix for consensus, remote crash, or memory safety | 14 days after triage |
| Fix for resource exhaustion | 30 days after triage |
| Fix for local-only and informational | 90 days after triage |
| Disclosure | When the fix is in a release, or sooner if the bug is being exploited. The default embargo after a fix is released is none: the release is the disclosure. A reporter can ask for a coordinated date up to 90 days after the fix. |

Severity labels, tied to node impact: chain split or consensus divergence, remote crash, resource exhaustion, local-only, and informational.

## Embargo and credit

We keep the report private until the fix is released, unless the bug is already public or actively exploited. We credit the reporter in the advisory when they agree in writing. Silence is not consent. The reconstructed November entries leave the reporter blank and set `reporter_consent` to `pending`.

## Advisories

The append-only record is one OSV JSON file per advisory id, plus a generated index. A correction is a new id that references the old one. Do not edit a published file. Public counts are generated from that record.

Advisory files are signed with the same key as release tags, once a signing key exists. They are unsigned until that key is configured.

Dependency advisories that affect a shipped build get an entry in the same record. `cargo audit` and `cargo deny` run in CI. Ignore entries belong in `.cargo/audit.toml` with a reason, not only in a workflow flag.

## Supported versions

Security fixes target the current beta line once `0.2.0-beta.1` is published. Until that tag exists, the supported line is the highest published `0.1.x` tag of the affected crate. Older `0.1` tags are not maintained as a second line.
