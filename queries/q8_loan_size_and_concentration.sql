-- Q8: loan size distribution and borrower concentration
-- Ethereum, Aave / Compound / Morpho / Spark, 2026-01-01 to 2026-08-31.
-- Rows without a USD value are excluded: a distribution cannot use NULLs.

WITH borrows AS (
    SELECT
        project,
        borrower,
        ABS(amount_usd) AS amount_usd
    FROM lending.borrow
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND transaction_type = 'borrow'
      AND borrower   IS NOT NULL
      AND amount_usd IS NOT NULL
      AND ABS(amount_usd) > 0
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
),

event_stats AS (
    SELECT
        project,
        COUNT(*)                                      AS borrow_events,
        SUM(amount_usd)                               AS total_borrow_usd,
        ROUND(AVG(amount_usd), 0)                     AS avg_borrow_usd,
        ROUND(approx_percentile(amount_usd, 0.50), 0) AS median_borrow_usd,
        ROUND(approx_percentile(amount_usd, 0.90), 0) AS p90_borrow_usd,
        ROUND(approx_percentile(amount_usd, 0.99), 0) AS p99_borrow_usd,
        ROUND(MAX(amount_usd), 0)                     AS max_borrow_usd
    FROM borrows
    GROUP BY 1
),

per_wallet AS (
    SELECT
        project,
        borrower,
        SUM(amount_usd) AS wallet_borrow_usd,
        ROW_NUMBER() OVER (PARTITION BY project
                           ORDER BY SUM(amount_usd) DESC) AS wallet_rank
    FROM borrows
    GROUP BY 1, 2
),

concentration AS (
    SELECT
        project,
        COUNT(*)                                                       AS unique_borrowers,
        SUM(wallet_borrow_usd)                                         AS wallet_total_usd,
        SUM(CASE WHEN wallet_rank <= 10  THEN wallet_borrow_usd END)   AS top10_usd,
        SUM(CASE WHEN wallet_rank <= 100 THEN wallet_borrow_usd END)   AS top100_usd
    FROM per_wallet
    GROUP BY 1
)

SELECT
    e.project AS protocol,
    e.borrow_events,
    c.unique_borrowers,
    e.total_borrow_usd,
    e.avg_borrow_usd,
    e.median_borrow_usd,
    e.p90_borrow_usd,
    e.p99_borrow_usd,
    e.max_borrow_usd,
    ROUND(100.0 * c.top10_usd  / NULLIF(c.wallet_total_usd, 0), 1) AS top10_share_pct,
    ROUND(100.0 * c.top100_usd / NULLIF(c.wallet_total_usd, 0), 1) AS top100_share_pct
FROM event_stats e
JOIN concentration c ON e.project = c.project
ORDER BY e.total_borrow_usd DESC
