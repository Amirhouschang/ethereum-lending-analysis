# Findings — Crypto Lending on Ethereum, Jan–Aug 2026

Detailed results behind the dashboard. All figures: Ethereum mainnet, 1 Jan – 31 Aug 2026 (UTC), Aave / Compound / Morpho / Spark. Volumes are transaction activity, not TVL.

## 1. Data check (Q0)

| Check | Result |
|-------|--------|
| Protocols selected | `aave`, `compound`, `morpho`, `spark` |
| Liquidation labels | `borrow_liquidation` (debt side); `deposit_liquidation` / `supply_liquidation` (collateral side) |
| Deposit labels | `deposit` (Aave, Morpho, Spark), `supply` (Compound) |
| Sign of `amount_usd` | Negative for withdrawals, repayments and liquidations → `ABS()` used |
| USD coverage | Aave 98.3% · Spark 100% · Morpho 89.7% · Compound 99.8% |
| Known data issues | Broken USD values in some Morpho collateral-side liquidation rows (not used); no Compound v2 borrow events |

## 2. Answers to the sub-questions

**Which protocol had the largest deposit and borrow volume? (Q1)**
Aave: $200.9B deposits, $57.2B borrows (66.8% of borrow volume). Then Spark ($14.8B, 17.2%), Morpho ($12.6B, 14.7%), Compound ($1.1B, 1.3%). Total borrow volume: $85.6B.

**How did deposits and withdrawals develop? (Q2)**
Deposits and withdrawals move almost in parallel every month — most supply activity is capital rotating in and out. The largest single spike is Morpho in March 2026 ($53.7B deposits, $53.4B withdrawals).

**How did borrowing develop? (Q3)**
Aave borrowing fell from $10.5–11.3B per month in January–March to $3.5–5.0B from May onwards. Spark rose from $1.0–1.2B per month in January–March to $2.0–3.2B in April–July.

**Which protocol had the most active users? (Q4)**
Aave by far: 5,300–10,200 active borrower wallets per month. Compound, Morpho and Spark each had between roughly 170 and 650.

**Which tokens were deposited and borrowed? (Q5)**
Borrow side: stablecoins dominate — about 77% on Aave, 79% on Morpho, 74% on Spark. Compound is the exception: WETH is its largest borrowed asset (43%). Deposit side: WETH leads on Aave (40%), USDC on Morpho (71%) and Compound (41%), USDT on Spark (37%).

**Do borrowers use one protocol or several? (Q6)**
39,965 unique borrower wallets in total. 97.5% use a single protocol and account for 60.2% of borrow volume. 2.6% use two or more and account for 39.8%. The largest multi-protocol group — 499 wallets on Aave and Spark — holds 28.6% of all borrow volume.

**Where were liquidations largest? (Q7a, Q7b, Q7d)**
Total liquidated debt: $844.7M, of which Aave $657.9M (77.9%). January, February and June account for 83.5% of the total. Relative to borrow volume, Compound shows the highest liquidation intensity (6.34%), then Aave (1.15%), Morpho (0.87%), Spark (0.05%). On Aave, USDT (60%) and USDC (28%) debt was liquidated most.

**How large is a typical loan, and how concentrated is borrowing? (Q8)**

| Protocol | Median loan | Average loan | Top 10 wallets | Top 100 wallets |
|----------|-------------|--------------|----------------|-----------------|
| Spark | $58.8K | $946.8K | 70.3% | 95.8% |
| Aave | $4.9K | $246.2K | 40.5% | 77.0% |
| Compound | $3.8K | $107.4K | 41.2% | 90.0% |
| Morpho | $2.4K | $137.8K | 85.8% | 98.2% |

On every protocol the average is far above the median: a small number of very large loans dominates volume.

## 3. Hypotheses

| # | Hypothesis | Result |
|---|------------|--------|
| H1 | Aave has the highest borrow volume | Confirmed |
| H2 | Stablecoins > 60% of borrow volume | Partly — true for Aave, Morpho, Spark; not for Compound (~57%) |
| H3 | Median loan differs by more than 2× between protocols | Confirmed — factor ~25 |
| H4 | Top 10 wallets > 25% of borrow volume on every protocol | Confirmed — 40.5% to 85.8% |
| H5 | Fewer than 10% of borrowers use several protocols | Confirmed — 2.6% |
| H6 | Liquidations cluster in a few months | Confirmed — 83.5% in Jan, Feb, Jun |

## 4. Spot checks

- **Largest Compound liquidation** ($27.7M, 9 May 2026, [tx](https://etherscan.io/tx/0x9c17cb1f32c5b4ff792b19c39a31119272d67c3eb6e03ef4cffc8578c568113e)): date, protocol and amount confirmed on Etherscan (11,999.8 WETH debt absorbed at ~$2,326/ETH). The transaction was sent by Compound's Community Multisig and absorbed a single rsETH-collateralised position — a governance action, not a regular market liquidation. Without it, Compound's liquidation intensity would be 3.8% instead of 6.3%.
- **Totals consistency**: borrow volume in Q1, Q7d and Q8 matches for every protocol; unique borrowers across protocols (39,965) are taken from Q6, not summed from Q1, to avoid double counting.
