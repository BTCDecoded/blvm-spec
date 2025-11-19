# Governance Model Specification
## Mathematical Description of Bitcoin Commons Governance System

**Section 15 of The Orange Paper**  
**Version 1.0**

---

## 15. Governance Model

### 15.1 Overview

The Bitcoin Commons governance system enables decentralized decision-making through contribution-based voting. The system uses quadratic weighting to prevent whale dominance while allowing all contributors to participate.

### 15.2 Mathematical Foundations

#### 15.2.1 Contribution Types

Let $\mathcal{C}$ be the set of all contributors, and define contribution types:

- **Merge Mining**: $\mathcal{M} = \{m_1, m_2, \ldots\}$ where $m_i \in \mathbb{R}_{\geq 0}$ (BTC contributed)
- **Fee Forwarding**: $\mathcal{F} = \{f_1, f_2, \ldots\}$ where $f_i \in \mathbb{R}_{\geq 0}$ (BTC forwarded)
- **Zap Contributions**: $\mathcal{Z} = \{z_1, z_2, \ldots\}$ where $z_i \in \mathbb{R}_{\geq 0}$ (BTC zapped)

For a contributor $c \in \mathcal{C}$:
- $M_c(t)$ = merge mining contributions in period $[t-30, t]$ (30-day rolling)
- $F_c(t)$ = fee forwarding contributions in period $[t-30, t]$ (30-day rolling)
- $Z_c$ = cumulative zap contributions (all-time)

#### 15.2.2 Total Contribution

For contributor $c$ at time $t$:

$$T_c(t) = M_c(t) + F_c(t) + Z_c$$

**Invariant**: $T_c(t) \geq 0$ for all $c, t$

#### 15.2.3 Participation Weight (Quadratic)

The participation weight for contributor $c$ at time $t$ is:

$$W_c(t) = \sqrt{T_c(t)}$$

**Properties**:
- **Monotonicity**: $T_{c1} < T_{c2} \implies W_{c1} < W_{c2}$
- **Subadditivity**: $W_{c1 + c2} < W_{c1} + W_{c2}$ (prevents whale dominance)
- **Non-negativity**: $W_c(t) \geq 0$ for all $c, t$

#### 15.2.4 Weight Cap

To prevent any single entity from dominating, weights are capped at 5% of total system weight:

$$W_{capped}(c, t) = \min\left(W_c(t), 0.05 \cdot \sum_{c' \in \mathcal{C}} W_{c'}(t)\right)$$

**Invariant**: For all $c \in \mathcal{C}$:
$$\frac{W_{capped}(c, t)}{\sum_{c' \in \mathcal{C}} W_{capped}(c', t)} \leq 0.05$$

#### 15.2.5 Cooling-Off Period

Large contributions require a cooling-off period before counting toward voting:

$$\text{Eligible}(c, t, a) = \begin{cases}
\text{true} & \text{if } T_c(t) < 0.1 \text{ BTC} \\
\text{true} & \text{if } T_c(t) \geq 0.1 \text{ and } a \geq 30 \text{ days} \\
\text{false} & \text{otherwise}
\end{cases}$$

Where $a$ is the age of the contribution.

**Invariant**: For contributions $\geq 0.1$ BTC:
$$\text{Eligible}(c, t, a) = \text{true} \iff a \geq 30$$

### 15.3 Vote Aggregation

#### 15.3.1 Vote Types

For a proposal $p$:
- **Support Votes**: $S_p = \{s_1, s_2, \ldots\}$ where $s_i \in \mathbb{R}_{\geq 0}$ (vote weights)
- **Veto Votes**: $V_p = \{v_1, v_2, \ldots\}$ where $v_i \in \mathbb{R}_{\geq 0}$ (vote weights)
- **Abstain Votes**: $A_p = \{a_1, a_2, \ldots\}$ where $a_i \in \mathbb{R}_{\geq 0}$ (vote weights)

#### 15.3.2 Total Vote Weight

$$S_{total}(p) = \sum_{s \in S_p} s$$
$$V_{total}(p) = \sum_{v \in V_p} v$$
$$A_{total}(p) = \sum_{a \in A_p} a$$
$$T_{total}(p) = S_{total}(p) + V_{total}(p) + A_{total}(p)$$

#### 15.3.3 Veto Thresholds

**Economic Node Veto** (Tier 3+):
- Mining veto: $\geq 30\%$ of network hashpower
- Economic veto: $\geq 40\%$ of economic activity
- **Veto Active**: $\text{MiningVeto} \geq 0.30 \lor \text{EconomicVeto} \geq 0.40$

**Zap Vote Veto** (All tiers):
- **Veto Active**: $\frac{V_{total}(p)}{T_{total}(p)} \geq 0.40$ (if $T_{total}(p) > 0$)

**Combined Veto**:
$$\text{VetoBlocks}(p) = \text{EconomicVetoActive}(p) \lor \text{ZapVetoActive}(p)$$

#### 15.3.4 Proposal Approval

A proposal $p$ is **approved** if:
1. $T_{total}(p) \geq \text{Threshold}(tier(p))$
2. $\neg \text{VetoBlocks}(p)$

Where $\text{Threshold}(tier)$ is tier-specific:
- Tier 1: 100
- Tier 2: 500
- Tier 3: 1,000
- Tier 4: 2,500
- Tier 5: 5,000

### 15.4 Security Properties

#### 15.4.1 Whale Resistance

**Theorem**: For any contributor $c$ with contribution $T_c$, their voting power is bounded:

$$W_{capped}(c) \leq 0.05 \cdot \sum_{c' \in \mathcal{C}} W_{capped}(c')$$

**Proof**: By definition of weight cap (Section 15.2.4).

#### 15.4.2 Quadratic Scaling

**Theorem**: Doubling contribution does not double voting power:

$$W(2T) = \sqrt{2T} = \sqrt{2} \cdot \sqrt{T} = \sqrt{2} \cdot W(T) < 2W(T)$$

**Proof**: By properties of square root function.

#### 15.4.3 Cooling-Off Protection

**Theorem**: Large contributions cannot immediately influence votes:

$$\forall c, t: T_c(t) \geq 0.1 \implies \text{Eligible}(c, t, a) = \text{false} \text{ for } a < 30$$

**Proof**: By definition of cooling-off period (Section 15.2.5).

### 15.5 Implementation Functions

#### 15.5.1 Weight Calculation

```rust
/// Calculate participation weight: W_c(t) = √(T_c(t))
/// 
/// Mathematical Specification:
/// ∀ c ∈ C, t ∈ ℝ: W_c(t) = √(M_c(t) + F_c(t) + Z_c)
/// 
/// Invariants:
/// - W_c(t) ≥ 0 (non-negativity)
/// - T_c1 < T_c2 ⟹ W_c1 < W_c2 (monotonicity)
fn calculate_participation_weight(
    merge_mining_btc: f64,
    fee_forwarding_btc: f64,
    cumulative_zaps_btc: f64,
) -> f64 {
    let total = merge_mining_btc + fee_forwarding_btc + cumulative_zaps_btc;
    total.sqrt()
}
```

#### 15.5.2 Weight Cap Application

```rust
/// Apply weight cap: W_capped = min(W, 0.05 · W_total)
/// 
/// Mathematical Specification:
/// ∀ c ∈ C: W_capped(c) = min(W_c, 0.05 · Σ W_capped(c'))
/// 
/// Invariant:
/// - W_capped(c) / Σ W_capped(c') ≤ 0.05 (5% cap)
fn apply_weight_cap(calculated_weight: f64, total_system_weight: f64) -> f64 {
    let max_weight = total_system_weight * 0.05;
    calculated_weight.min(max_weight)
}
```

#### 15.5.3 Cooling-Off Check

```rust
/// Check cooling-off eligibility
/// 
/// Mathematical Specification:
/// Eligible(c, t, a) = (T_c < 0.1) ∨ (T_c ≥ 0.1 ∧ a ≥ 30)
/// 
/// Invariant:
/// - T_c ≥ 0.1 ⟹ (Eligible(c, t, a) ⟺ a ≥ 30)
fn check_cooling_off(contribution_amount_btc: f64, contribution_age_days: u32) -> bool {
    if contribution_amount_btc >= 0.1 {
        contribution_age_days >= 30
    } else {
        true  // No cooling-off for small contributions
    }
}
```

---

## References

- Quadratic Voting: Posner & Weyl (2018), "Radical Markets"
- Weight Caps: Prevent whale dominance in governance
- Cooling-Off Periods: Prevent vote buying and timing attacks

