# Orange Paper Format Guide for Spec-Macro Extraction

This document describes the format requirements for the Orange Paper to enable automatic extraction of function specifications and generation of blvm-spec-lock contracts.

## Function Definition Format

Functions should be defined using this format:

```markdown
**FunctionName**: $\mathbb{N} \rightarrow \mathbb{Z}$

$$\text{FunctionName}(h) = \begin{cases}
0 & \text{if } h \geq 64 \times H \\
50 \times C \times 2^{-\lfloor h/H \rfloor} & \text{otherwise}
\end{cases}$$

Description of what the function does.
```

## Theorem Format

Theorems should use this format for automatic extraction:

```markdown
**Theorem X.Y.Z** (Property Name): Statement

$$\forall h \in \mathbb{N}: \text{Property}(h)$$
```

## Property Lists

Properties can be listed as:

```markdown
- **Property Name**: Mathematical statement
- **Invariant**: $\forall h: \text{condition}(h)$
```

## Named formula blocks (`F_*`) — spec-lock registry

Stable **formula** ids bind to **`#[spec_locked("§", "F_Id")]`** (or combined **`"§::F_Id"`**) in Rust. The **blvm-spec-lock** parser ingests **`**Formula**` headings into **`SpecParser::formulas()`**; duplicate ids across merged files are errors.

Use this layout (exact bold pattern on one line):

```markdown
### A.B Example subsection

Intro prose…

**Formula** (**F_YourStableId**):

$$\text{Trivial}(\text{v1})$$

Optional prose after the **`$$`** block (not part of **`latex_body`**).
```

**Rules:**

- **`F_YourStableId`** must match **`^F_[A-Za-z0-9_]+$`**.
- Body is **only** the first **`$$ … $$`** (display math) after the **`Formula`** line.
- The § id is the Markdown heading (**`### A.B`** → section key **`A.B`**).

**Reference:** **`PROTOCOL.md`** §**13.3.6** (**`F_SpecLockWitness`**) documents a canonical trivial formula for named-formula verification.

## Authoring checklist

When adding or revising spec text, confirm:
- Function names use the **`**Name**:`** heading pattern consistently.
- Theorems use stable **`Theorem X.Y.Z`** numbering and parseable math.
- Properties use formal notation where **blvm-spec-lock** must extract contracts.
- Named **`F_*`** **Formula** blocks follow the grammar above when bound via **`#[spec_locked]`**.














