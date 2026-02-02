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

## Current Status

The Orange Paper already follows most of these conventions. Minor adjustments may be needed for:
- Consistent function name formatting
- Theorem naming conventions
- Property extraction from prose




