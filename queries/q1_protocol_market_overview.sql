-- Q1: protocol market overview
-- Ethereum, 2026-01-01 to 2026-08-31. Versions aggregated.
-- Q0 findings applied: Compound labels deposits as 'supply';
-- outflow amounts (withdraw, repay, liquidation) are negative in the source.

WITH supply_side AS (
    SELECT
        project,
        SUM(CASE WHEN transaction_type IN ('deposit', 'supply')
                 THEN ABS(amount_usd) END)                            AS deposit_usd,
        SUM(CASE WHEN transaction_type = 'withdraw'
                 THEN ABS(amount_usd) END)                            AS withdraw_usd,
        COUNT(DISTINCT CASE WHEN transaction_type IN ('deposit', 'supply')
                            THEN depositor END)                       AS unique_depositors,
        COUNT(*)                                                      AS supply_rows,
        COUNT(amount_usd)                                             AS supply_rows_with_usd
    FROM lending.supply
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
    GROUP BY 1
),

borrow_side AS (
    SELECT
        project,
        SUM(CASE WHEN transaction_type = 'borrow'
                 THEN ABS(amount_usd) END)                            AS borrow_usd,
        SUM(CASE WHEN transaction_type = 'repay'
                 THEN ABS(amount_usd) END)                            AS repay_usd,
        SUM(CASE WHEN transaction_type = 'borrow_liquidation'
                 THEN ABS(amount_usd) END)                            AS debt_liquidated_usd,
        COUNT(CASE WHEN transaction_type = 'borrow' THEN 1 END)       AS borrow_events,
        COUNT(DISTINCT CASE WHEN transaction_type = 'borrow'
                            THEN borrower END)                        AS unique_borrowers,
        COUNT(*)                                                      AS borrow_rows,
        COUNT(amount_usd)                                             AS borrow_rows_with_usd
    FROM lending.borrow
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
    GROUP BY 1
)

SELECT
    COALESCE(s.project, b.project)                                    AS protocol,
    s.deposit_usd,
    s.withdraw_usd,
    b.borrow_usd,
    b.repay_usd,
    b.debt_liquidated_usd,
    b.borrow_events,
    s.unique_depositors,
    b.unique_borrowers,
    ROUND(100.0 * b.borrow_usd / SUM(b.borrow_usd) OVER (), 1)        AS borrow_share_pct,
    ROUND(100.0 * (s.supply_rows_with_usd + b.borrow_rows_with_usd)
                / (s.supply_rows        + b.borrow_rows), 2)          AS usd_coverage_pct
FROM supply_side s
FULL OUTER JOIN borrow_side b ON s.project = b.project
ORDER BY b.borrow_usd DESC
