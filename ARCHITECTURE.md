# Architecture: Implementation Algorithms and Design Choices

This document contains the implementation-oriented sections of the Orange Paper.
See [PROTOCOL.md](PROTOCOL.md) for consensus rules and predicates.


### 10.2 Connection Management

**Connection Types**:
- **Outbound**: Active connections to other nodes
- **Inbound**: Passive connections from other nodes  
- **Feeler**: Short-lived connections for peer discovery
- **Block-Relay**: Connections that only relay blocks

### 10.3 Peer Discovery

**AddrMan**: Address manager maintaining peer database

**GetAddr**: Request peer addresses from connected nodes
**Addr**: Broadcast known peer addresses

### 10.6 Dandelion++ k-Anonymity

*Full specification: [DANDELION_SPEC.md in blvm-node](https://github.com/BTCDecoded/blvm-node/blob/main/docs/DANDELION_SPEC.md). This section retains the k-anonymity definition, stem phase algorithm, and Implementation Invariants for spec-lock verification.*

**Adversary Model**: Passive observer capable of monitoring network traffic, operating nodes, and performing graph analysis.

**k-Anonymity Definition**: A transaction $tx$ satisfies k-anonymity if, from the adversary's perspective, $tx$ could have originated from at least $k$ distinct nodes with equal probability.

Formally, let:
- $O$ = set of nodes that could have originated $tx$ (from adversary's view)
- $P(O = N_i | \text{Evidence})$ = probability that node $N_i$ originated $tx$ given observed evidence

Then $tx$ has **k-anonymity** if:
- $|O| \geq k$
- $\forall N_i, N_j \in O: P(O = N_i | \text{Evidence}) = P(O = N_j | \text{Evidence})$

**Stem Phase Parameters**:
- $p_{\text{fluff}} \in [0, 1]$: Probability of transitioning to fluff at each hop (default: 0.1)
- $\text{max\_stem\_hops} \in \mathbb{N}$: Maximum number of stem hops before forced fluff (default: 2)
- $\text{stem\_timeout} \in \mathbb{R}^+$: Maximum duration (seconds) in stem phase before timeout fluff

**Stem Phase Algorithm**:
$$\text{stem\_phase\_relay}(tx, \text{current\_peer}, \text{peers}) \rightarrow \text{Option}<\text{Peer}>$$

1. If $tx$ already in stem phase:
   - If $\text{elapsed\_time}(tx) > \text{stem\_timeout}$: return $\text{None}$ (fluff via timeout)
   - If $\text{hop\_count}(tx) \geq \text{max\_stem\_hops}$: return $\text{None}$ (fluff via hop limit)
   - If $\text{random}() < p_{\text{fluff}}$: return $\text{None}$ (fluff via probability)
   - Otherwise: $\text{advance\_stem}(tx)$ → return $\text{Some}(\text{next\_peer})$

2. Else: $\text{start\_stem\_phase}(tx)$ → return $\text{Some}(\text{next\_peer})$

**Fluff Phase**: When algorithm returns $\text{None}$, transaction enters fluff phase and is broadcast to all peers (standard Bitcoin relay).

**Theorem 1 (Stem Phase Anonymity)**: During the stem phase, if the adversary observes a transaction at node $N_i$, the set of possible originators includes all nodes that have been on the stem path up to $N_i$.

**Proof Sketch**: The adversary cannot distinguish between:
1. $tx$ originated at $N_i$ and is in its first stem hop
2. $tx$ originated at any previous node $N_j$ ($j < i$) and is being forwarded

The random peer selection ensures uniform probability distribution over all possible originators in the path.

**Theorem 2 (Minimum k-Anonymity)**: For a stem path of length $h$ hops, the minimum k-anonymity is $k \geq h + 1$.

**Proof**: A stem path $N_0 \rightarrow N_1 \rightarrow \ldots \rightarrow N_h$ contains $h + 1$ nodes. From the adversary's perspective at $N_h$, any of these $h + 1$ nodes could have originated $tx$. Therefore, $k \geq h + 1$.

**Corollary**: With $\text{max\_stem\_hops} = 2$, we guarantee $k \geq 3$ (3-anonymity).

**Theorem 3 (Timeout Guarantee)**: Even if the adversary controls all peers except the originator, the stem phase will terminate within $\text{stem\_timeout}$ seconds.

**Proof**: The timeout check ensures $tx$ transitions to fluff phase within $\text{stem\_timeout}$ seconds regardless of peer behavior.

**Theorem 4 (No Premature Broadcast)**: During the stem phase, a transaction is never broadcast to multiple peers simultaneously.

**Proof**: The algorithm returns $\text{Option}<\text{Peer}>$ where $\text{Some}(\text{peer})$ indicates single-peer relay and $\text{None}$ indicates transition to fluff. The fluff phase is the only mechanism for broadcast.

**Implementation Invariants (BLVM Specification Lock Verified)**:
1. **No Premature Broadcast**: $\forall tx, \text{phase}: \text{phase} = \text{Stem} \implies \text{broadcast\_count}(tx) = 0$
2. **Bounded Stem Length**: $\forall tx: \text{stem\_hops}(tx) \leq \text{max\_stem\_hops}$
3. **Timeout Enforcement**: $\forall tx: \text{elapsed\_time}(tx) > \text{stem\_timeout} \implies \text{phase}(tx) = \text{Fluff}$
4. **Single Stem State**: $\forall tx: |\text{stem\_states}(tx)| \leq 1$
5. **Eventual Fluff**: $\forall tx: \exists t: \text{phase\_at\_time}(tx, t) = \text{Fluff}$

### 11.3 Chain Reorganization

**Chain Selection**: Choose chain with most cumulative work
$$\text{BestChain} = \arg\max_{chain} \sum_{block \in chain} \text{Work}(block)$$

**Reorganization**: When a longer chain is found:
1. Disconnect blocks from current tip
2. Connect blocks from new chain
3. Update UTXO set accordingly

#### 11.3.1 Undo Log Pattern

Chain reorganization requires disconnecting blocks from the current chain and connecting blocks from the new chain. To efficiently reverse the effects of `ConnectBlock`, we use an undo log pattern that records all UTXO set changes made by a block.

**Undo Entry**: $\mathcal{UE} = \mathcal{O} \times \mathcal{U}^? \times \mathcal{U}^?$

An undo entry records:
- `outpoint`: The outpoint that was changed
- `previous_utxo`: The UTXO that existed before (None if created)
- `new_utxo`: The UTXO that exists after (None if spent)

**Block Undo Log**: $\mathcal{UL} = \mathcal{UE}^*$

A block undo log contains all undo entries for a block, stored in reverse order (most recent first) to allow efficient undo by iterating forward.

**DisconnectBlock**: $\mathcal{B} \times \mathcal{UL} \times \mathcal{US} \rightarrow \mathcal{US}$

**Properties**:
- Undo correctness: $\text{DisconnectBlock}(b, ul, us) = us' \implies$ UTXO set $us'$ reflects state before block $b$ was connected
- Idempotency: $\text{DisconnectBlock}(b, ul, \text{ConnectBlock}(b, us, h)) = us$ (perfect inverse)
- Undo log length: $|\text{DisconnectBlock}(b, ul, us)| = |us| - |ul|$ (undo log entries match block changes)

For block $b$, undo log $ul$, and UTXO set $us$:

$$\text{DisconnectBlock}(b, ul, us) = \begin{cases}
us' & \text{where } us' = \text{ApplyUndoLog}(ul, us) \\
\text{error} & \text{if undo log is invalid}
\end{cases}$$

Where $\text{ApplyUndoLog}$ processes each entry $e \in ul$ in order:
- If $e.\text{new\_utxo} \neq \text{None}$: $us' = us' \setminus \{e.\text{outpoint}\}$ (remove UTXO created by block)
- If $e.\text{previous\_utxo} \neq \text{None}$: $us' = us' \cup \{e.\text{outpoint} \mapsto e.\text{previous\_utxo}\}$ (restore UTXO spent by block)

**Theorem 11.3.1** (Disconnect/Connect Idempotency): Disconnect and connect operations are perfect inverses:

$$\forall b \in \mathcal{B}, us \in \mathcal{US}, ul \in \mathcal{UL}:$$
$$\text{DisconnectBlock}(b, ul, \text{ConnectBlock}(b, us)) = us$$

*Proof*: By construction, the undo log $ul$ created during $\text{ConnectBlock}$ records all UTXO changes. When $\text{DisconnectBlock}$ applies the undo log, it reverses each change exactly, restoring the original UTXO set. This is proven by blvm-spec-lock formal verification.

**Corollary 11.3.1.1**: Undo logs enable perfect historical state restoration without re-validating blocks.


### 12.1 Block Template Generation

*One valid algorithm. Protocol requires output passes ConnectBlock; this section describes one way to construct a valid block template.*

**CreateNewBlock**: $\mathcal{US} \times \mathcal{TX}^* \rightarrow \mathcal{B}$

**Properties**:
- Block structure: $\text{CreateNewBlock}(us, mempool)$ returns a block with at least one transaction (coinbase)
- Coinbase requirement: First transaction in block is coinbase: $\text{CreateNewBlock}(us, mempool) = block \implies \text{IsCoinbase}(block.transactions[0]) = \text{true}$
- Transaction ordering: Coinbase is first, followed by mempool transactions
- Block validity: $\text{CreateNewBlock}(us, mempool) = block \implies \text{CheckTransaction}(block.transactions[0]) = \text{valid}$ (coinbase is valid)
- Difficulty validity: $\text{CreateNewBlock}(us, mempool) = block \implies block.header.bits > 0$ (valid difficulty)
- Minimum transactions: $\text{CreateNewBlock}(us, mempool) = block \implies |block.transactions| \geq 1$ (at least coinbase)
- Deterministic structure: Block structure follows deterministic rules (coinbase first, then mempool transactions)
- Merkle root: $\text{CreateNewBlock}(us, mempool) = block \implies block.header.hashMerkleRoot = \text{BlockMerkleRoot}(block.transactions)$

For UTXO set $us$ and mempool transactions $mempool$:

1. **Initialize Block**: Create empty block with dummy coinbase
2. **Set Version**: $block.version = \text{ComputeBlockVersion}(prevBlock)$
3. **Set Time**: $block.time = \text{CurrentTime}()$
4. **Add Transactions**: Select transactions from mempool respecting weight limits
5. **Create Coinbase**: Generate coinbase transaction (see [Coinbase Transaction](#122-coinbase-transaction))
6. **Set Header**: $block.hashPrevBlock = prevBlock.hash$, $block.nBits = \text{GetNextWorkRequired}(h, prev, n)$
7. **Initialize Nonce**: $block.nNonce = 0$



### 12.3 Mining Process

*One valid algorithm. Protocol requires CheckProofOfWork(block) = true; this section describes one mining loop.*

**MineBlock**: $\mathcal{B} \times \mathbb{N} \rightarrow \mathcal{B} \times \{\text{success}, \text{failure}\}$

**Properties**:
- PoW success: $\text{MineBlock}(block, maxTries) = (block', \text{success}) \implies \text{CheckProofOfWork}(block') = \text{true}$ (mined block passes PoW)
- Merkle root: $\text{MineBlock}(block, maxTries) = (block', \_) \implies block'.\text{hashMerkleRoot} = \text{BlockMerkleRoot}(block')$ (merkle root is correct)
- Nonce modification: $\text{MineBlock}(block, maxTries) = (block', \text{success}) \implies block'.\text{nonce} \neq block.\text{nonce}$ (nonce changed during mining)
- Max attempts: $\text{MineBlock}(block, maxTries)$ requires $maxTries > 0$ (must have at least one attempt)
- Result type: $\text{MineBlock}(block, maxTries) \in \{(\mathcal{B}, \text{success}), (\mathcal{B}, \text{failure})\}$
- Failure condition: $\text{MineBlock}(block, maxTries) = (block', \text{failure}) \implies$ all $maxTries$ attempts failed to find valid PoW
- Success condition: $\text{MineBlock}(block, maxTries) = (block', \text{success}) \implies$ found valid PoW within $maxTries$ attempts
- Block structure preserved: $\text{MineBlock}(block, maxTries) = (block', \_) \implies$ all block fields except nonce and hash remain unchanged

For block template $block$ and max attempts $maxTries$:

1. **Set Merkle Root**: $block.hashMerkleRoot = \text{BlockMerkleRoot}(block)$
2. **Proof of Work**: While $maxTries > 0$ and $\neg \text{CheckProofOfWork}(block)$:
   - Increment $block.nNonce$
   - Decrement $maxTries$
3. **Return Result**: If valid proof found, return $(block, \text{success})$, else $(\bot, \text{failure})$

```mermaid
sequenceDiagram
    participant M as Miner
    participant T as Block Template
    participant P as Proof of Work
    participant N as Network
    
    Note over M,N: Mining Process
    
    M->>T: CreateNewBlock()
    T->>M: Block Template
    
    M->>M: Set Merkle Root
    M->>M: Initialize Nonce = 0
    
    loop Mining Loop
        M->>P: CheckProofOfWork(block)
        P->>M: Hash < Target?
        
        alt Valid Proof Found
            P->>M: ✅ Success
            M->>N: Submit Block
            N->>M: Block Accepted
        else Invalid Proof
            M->>M: Increment Nonce
            M->>M: Decrement maxTries
            
            alt maxTries = 0
                M->>M: ❌ Mining Failed
            end
        end
    end
    
    Note over M,N: Block Template includes:
    - Previous block hash
    - Merkle root of transactions
    - Timestamp
    - Difficulty target
    - Nonce (incremented during mining)
```

### 13.1 Performance

- **UTXO Set**: Maintain in-memory for $O(1)$ lookups
- **Script Caching**: Cache verification results
- **Parallel Validation**: Validate transactions concurrently

### 13.2 Security

- **Malleability**: Prevented through SegWit
- **DoS Protection**: Resource limits on size and operations
- **Replay Protection**: Sequence numbers and locktime


### 13.4 Peer Consensus Protocol

*One valid algorithm. Protocol requires UTXO commitment verification; this section describes one peer consensus approach.*

The peer consensus protocol implements an N-of-M consensus model for UTXO commitment verification. It discovers diverse peers and finds consensus among them to verify UTXO commitments without trusting any single peer. This protocol is used in conjunction with UTXO commitments (section 11.4) to enable efficient UTXO set synchronization.

**Peer Information**: $\mathcal{PI} = \mathbb{IP} \times \mathbb{N}^? \times \mathbb{S}^? \times \mathbb{S}^? \times \mathbb{N}$

A peer information structure contains:
- `address`: IP address of the peer
- `asn`: Autonomous System Number (optional)
- `country`: Country code (optional)
- `implementation`: Bitcoin implementation identifier (optional)
- `subnet`: Subnet identifier for diversity checks (/16 for IPv4, /32 for IPv6)

**DiscoverDiversePeers**: $[\mathcal{PI}] \times \mathbb{N} \times \mathbb{N} \rightarrow [\mathcal{PI}]$

**Properties**:
- Subset property: $\text{DiscoverDiversePeers}(peers, max\_asn, target) \subseteq peers$ (no new peers created)
- ASN diversity: $\forall p_1, p_2 \in \text{DiscoverDiversePeers}(peers, max\_asn, target): p_1.\text{asn} = p_2.\text{asn} \implies |\{p \in \text{result} : p.\text{asn} = p_1.\text{asn}\}| \leq max\_asn$ (ASN limit enforced)
- Subnet diversity: $\forall p_1, p_2 \in \text{DiscoverDiversePeers}(peers, max\_asn, target): p_1 \neq p_2 \implies p_1.\text{subnet} \neq p_2.\text{subnet}$ (no duplicate subnets)
- Size bound: $|\text{DiscoverDiversePeers}(peers, max\_asn, target)| \leq \min(|peers|, target)$ (result size bounded)
- Deterministic: $\text{DiscoverDiversePeers}(peers_1, max\_asn_1, target_1) = \text{DiscoverDiversePeers}(peers_2, max\_asn_2, target_2) \iff peers_1 = peers_2 \land max\_asn_1 = max\_asn_2 \land target_1 = target_2$

For peer list $peers$, maximum peers per ASN $max\_asn$, and target number $target$:

$$\text{DiscoverDiversePeers}(peers, max\_asn, target) = \begin{cases}
result & \text{where } result \subseteq peers \land \\
& \quad \forall asn: |\{p \in result : p.\text{asn} = asn\}| \leq max\_asn \land \\
& \quad \forall p_1, p_2 \in result: p_1 \neq p_2 \implies p_1.\text{subnet} \neq p_2.\text{subnet} \land \\
& \quad |result| \leq target \\
peers & \text{if } |peers| \leq target \land \text{diversity constraints satisfied}
\end{cases}$$

**DetermineCheckpointHeight**: $[\mathbb{N}] \times \mathbb{N} \rightarrow \mathbb{N}$

**Properties**:
- Median bounds: $\text{DetermineCheckpointHeight}(tips, margin) = h \implies h \in [\min(tips) - margin, \max(tips)]$ (checkpoint within tip range)
- Non-negative: $\text{DetermineCheckpointHeight}(tips, margin) \geq 0$ (checkpoint is non-negative)
- Empty input: $\text{DetermineCheckpointHeight}([], margin) = 0$ (empty tips return genesis)
- Safety margin: $\text{DetermineCheckpointHeight}(tips, margin) \leq \text{median}(tips)$ (checkpoint at or below median)
- Deterministic: $\text{DetermineCheckpointHeight}(tips_1, margin_1) = \text{DetermineCheckpointHeight}(tips_2, margin_2) \iff tips_1 = tips_2 \land margin_1 = margin_2$

For peer tips $tips \in [\mathbb{N}]$ and safety margin $margin \in \mathbb{N}$:

$$\text{DetermineCheckpointHeight}(tips, margin) = \begin{cases}
0 & \text{if } |tips| = 0 \\
\max(0, \text{median}(tips) - margin) & \text{if } \text{median}(tips) > margin \\
0 & \text{otherwise}
\end{cases}$$

Where $\text{median}(tips)$ is the median value of sorted $tips$:
- If $|tips|$ is odd: $\text{median}(tips) = tips[\lfloor |tips|/2 \rfloor]$
- If $|tips|$ is even: $\text{median}(tips) = \lfloor (tips[|tips|/2 - 1] + tips[|tips|/2]) / 2 \rfloor$

**FindConsensus**: $[\mathcal{PC}] \times \mathbb{N} \times [0,1] \rightarrow \mathcal{CR}^?$

Where $\mathcal{PC} = \mathcal{PI} \times \mathcal{UC}$ is a peer commitment (peer info + UTXO commitment) and $\mathcal{CR} = \mathcal{UC} \times \mathbb{N} \times \mathbb{N} \times [0,1]$ is a consensus result (commitment, agreement count, total peers, agreement ratio).

**Properties**:
- Minimum peers: $\text{FindConsensus}(peer\_commitments, min\_peers, threshold) = \text{Some}(result) \implies |peer\_commitments| \geq min\_peers$ (requires minimum peers)
- Threshold requirement: $\text{FindConsensus}(peer\_commitments, min\_peers, threshold) = \text{Some}(result) \implies result.\text{agreement\_ratio} \geq threshold$ (meets threshold)
- Agreement count: $\text{FindConsensus}(peer\_commitments, min\_peers, threshold) = \text{Some}(result) \implies result.\text{agreement\_count} \geq \lceil |peer\_commitments| \times threshold \rceil$ (integer threshold)
- Consensus commitment: $\text{FindConsensus}(peer\_commitments, min\_peers, threshold) = \text{Some}(result) \implies$ at least $\lceil |peer\_commitments| \times threshold \rceil$ peers agree on $result.\text{commitment}$
- No consensus: $\text{FindConsensus}(peer\_commitments, min\_peers, threshold) = \text{None} \implies$ no commitment meets threshold
- Deterministic: $\text{FindConsensus}(pc_1, min_1, t_1) = \text{FindConsensus}(pc_2, min_2, t_2) \iff pc_1 = pc_2 \land min_1 = min_2 \land t_1 = t_2$

For peer commitments $peer\_commitments \in [\mathcal{PC}]$, minimum peers $min\_peers \in \mathbb{N}$, and threshold $threshold \in [0,1]$:

$$\text{FindConsensus}(peer\_commitments, min\_peers, threshold) = \begin{cases}
\text{Some}(result) & \text{if } |peer\_commitments| \geq min\_peers \land \\
& \quad \exists c \in \mathcal{UC}: \frac{|\{pc \in peer\_commitments : pc.\text{commitment} = c\}|}{|peer\_commitments|} \geq threshold \\
\text{None} & \text{otherwise}
\end{cases}$$

Where $result = (c, agreement\_count, |peer\_commitments|, agreement\_count / |peer\_commitments|)$ and $c$ is the commitment with highest agreement.

**VerifyConsensusCommitment**: $\mathcal{CR} \times [\mathcal{H}] \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- PoW verification: $\text{VerifyConsensusCommitment}(consensus, headers) = \text{valid} \implies \text{VerifyPoW}(headers) = \text{true}$ (PoW must be valid)
- Supply verification: $\text{VerifyConsensusCommitment}(consensus, headers) = \text{valid} \implies \text{VerifySupply}(consensus.\text{commitment}.\text{total\_supply}, consensus.\text{commitment}.\text{block\_height}) = \text{true}$ (supply must be valid)
- Block hash match: $\text{VerifyConsensusCommitment}(consensus, headers) = \text{valid} \implies headers[consensus.\text{commitment}.\text{block\_height}].\text{hash} = consensus.\text{commitment}.\text{block\_hash}$ (block hash matches)
- Height bounds: $\text{VerifyConsensusCommitment}(consensus, headers) = \text{valid} \implies consensus.\text{commitment}.\text{block\_height} < |headers|$ (height within header chain)
- Deterministic: $\text{VerifyConsensusCommitment}(c_1, h_1) = \text{VerifyConsensusCommitment}(c_2, h_2) \iff c_1 = c_2 \land h_1 = h_2$

For consensus result $consensus \in \mathcal{CR}$ and header chain $headers \in [\mathcal{H}]$:

$$\text{VerifyConsensusCommitment}(consensus, headers) = \begin{cases}
\text{valid} & \text{if } \text{VerifyPoW}(headers) \land \\
& \quad \text{VerifySupply}(consensus.\text{commitment}.\text{total\_supply}, consensus.\text{commitment}.\text{block\_height}) \land \\
& \quad consensus.\text{commitment}.\text{block\_height} < |headers| \land \\
& \quad headers[consensus.\text{commitment}.\text{block\_height}].\text{hash} = consensus.\text{commitment}.\text{block\_hash} \\
\text{invalid} & \text{otherwise}
\end{cases}$$

**VerifyUTXOProofs**: $\mathcal{CR} \times [(\mathcal{O}, \mathcal{U}, \mathcal{MP})] \rightarrow \{\text{valid}, \text{invalid}\}$

Where $\mathcal{MP}$ is a Merkle proof for UTXO inclusion.

**Properties**:
- Proof validity: $\text{VerifyUTXOProofs}(consensus, proofs) = \text{valid} \implies \forall (outpoint, utxo, proof) \in proofs: \text{VerifyMerkleProof}(consensus.\text{commitment}.\text{merkle\_root}, outpoint, utxo, proof) = \text{true}$ (all proofs valid)
- UTXO inclusion: $\text{VerifyUTXOProofs}(consensus, proofs) = \text{valid} \implies \forall (outpoint, utxo, proof) \in proofs: utxo \in \text{UTXOSet}(consensus.\text{commitment})$ (all UTXOs in commitment)
- Deterministic: $\text{VerifyUTXOProofs}(c_1, p_1) = \text{VerifyUTXOProofs}(c_2, p_2) \iff c_1 = c_2 \land p_1 = p_2$

For consensus result $consensus \in \mathcal{CR}$ and UTXO proofs $proofs \in [(\mathcal{O}, \mathcal{U}, \mathcal{MP})]$:

$$\text{VerifyUTXOProofs}(consensus, proofs) = \begin{cases}
\text{valid} & \text{if } \forall (outpoint, utxo, proof) \in proofs: \\
& \quad \text{VerifyMerkleProof}(consensus.\text{commitment}.\text{merkle\_root}, outpoint, utxo, proof) = \text{true} \\
\text{invalid} & \text{otherwise}
\end{cases}$$

**Theorem 13.4.1** (Peer Diversity Correctness): Diverse peer discovery ensures network diversity:

$$\forall peers \in [\mathcal{PI}], max\_asn \in \mathbb{N}, target \in \mathbb{N}:$$
$$\text{DiscoverDiversePeers}(peers, max\_asn, target) \text{ ensures ASN and subnet diversity}$$

*Proof*: By construction, the algorithm filters peers to ensure no more than $max\_asn$ peers per ASN and no duplicate subnets. This ensures geographic and network diversity, reducing the risk of coordinated attacks. This is proven by blvm-spec-lock formal verification.

**Theorem 13.4.2** (Checkpoint Safety): Checkpoint height determination prevents deep reorganizations:

$$\forall tips \in [\mathbb{N}], margin \in \mathbb{N}:$$
$$\text{DetermineCheckpointHeight}(tips, margin) \leq \text{median}(tips) - margin$$

*Proof*: The checkpoint is calculated as $\max(0, \text{median}(tips) - margin)$, ensuring it is always at least $margin$ blocks behind the median tip. This provides safety margin against deep reorganizations. This is proven by blvm-spec-lock formal verification.

**Theorem 13.4.3** (Consensus Threshold Correctness): Consensus finding correctly implements threshold-based agreement:

$$\forall peer\_commitments \in [\mathcal{PC}], min\_peers \in \mathbb{N}, threshold \in [0,1]:$$
$$\text{FindConsensus}(peer\_commitments, min\_peers, threshold) = \text{Some}(result) \iff$$
$$|peer\_commitments| \geq min\_peers \land \frac{result.\text{agreement\_count}}{|peer\_commitments|} \geq threshold$$

*Proof*: The algorithm groups commitments by their values and finds the group with highest agreement. If the agreement ratio meets the threshold, consensus is found. This ensures that a sufficient fraction of peers agree on the commitment. This is proven by blvm-spec-lock formal verification.

## 14. Conclusion

This Orange Paper is a **complete, definitive** mathematical specification of Bitcoin consensus within the scope of PROTOCOL.md and this document (see each table of contents). BLVM validates it through **extensive differential testing against Bitcoin Core**, integration tests on consensus crates, and **mainnet-observable behavior**; when a discrepancy appears, implementation and this specification are reconciled so the rules here remain the single authoritative statement for what “consensus correct” means in scope.

### 14.1 Summary of Contributions

**Complete protocol specification (in scope)**: The formalized topics include, among others:
- Transaction and block validation rules
- Script execution semantics  
- Economic model with formal proofs
- Proof-of-work and difficulty adjustment
- Network protocol and mempool management
- Mining process and block template generation

**Mathematical Rigor**: The specification uses formal mathematical notation throughout, making it suitable for:
- Formal verification tools
- Academic research
- Protocol analysis and development
- Security auditing

### 14.2 Applications

This specification can be used for:
- **Formal Verification**: Proving correctness properties of Bitcoin implementations
- **Protocol Analysis**: Understanding the security and economic properties of Bitcoin
- **Implementation Reference**: Building new Bitcoin-compatible software
- **Academic Research**: Studying distributed consensus and cryptocurrency systems

The specification covers the topics it defines, from basic transaction validation through economic rules and the network or mining material in its tables of contents. It is a formal specification for analysis and implementation, not an executable node implementation.

## References

### Bitcoin Protocol
1. [Reference implementation (bitcoin/bitcoin)](https://github.com/bitcoin/bitcoin)
2. [Bitcoin Improvement Proposals (BIPs)](https://github.com/bitcoin/bips)
3. Satoshi Nakamoto, ["Bitcoin: A Peer-to-Peer Electronic Cash System"](https://bitcoin.org/bitcoin.pdf) (2008)

### Cryptographic Standards
4. [FIPS 180-4: Secure Hash Standard](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf)
5. [SEC 2: Recommended Elliptic Curve Domain Parameters](https://www.secg.org/sec2-v2.pdf)
6. [RFC 6979: Deterministic Usage of DSA and ECDSA](https://tools.ietf.org/html/rfc6979)

### Mathematical Concepts
7. [Set Theory](https://en.wikipedia.org/wiki/Set_theory)
8. [Discrete Mathematics](https://en.wikipedia.org/wiki/Discrete_mathematics)
9. [Cryptographic Hash Function](https://en.wikipedia.org/wiki/Cryptographic_hash_function)
10. [Elliptic Curve Cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography)

### Security Vulnerabilities
11. [CVE-2012-2459: Bitcoin Merkle Tree Vulnerability](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2012-2459)
