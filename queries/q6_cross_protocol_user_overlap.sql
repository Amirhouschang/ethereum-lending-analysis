-- Q6: cross-protocol borrower overlap
-- Each borrower wallet is assigned to exactly one combination of protocols.
-- Ethereum, Aave / Compound / Morpho / Spark, 2026-01-01 to 2026-08-31.

WITH borrows AS (
    SELECT
        borrower        AS wallet,
        project,
        ABS(amount_usd) AS amount_usd
    FROM lending.borrow
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND transaction_type = 'borrow'
      AND borrower IS NOT NULL
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
),

wallet_profile AS (
    SELECT
        wallet,
        array_sort(array_agg(DISTINCT project)) AS protocols,
        SUM(amount_usd)                         AS wallet_borrow_usd
    FROM borrows
    GROUP BY wallet
)

SELECT
    array_join(protocols, ' + ')                                      AS protocol_combination,
    cardinality(protocols)                                            AS protocol_count,
    COUNT(*)                                                          AS borrowers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)                AS borrower_share_pct,
    SUM(wallet_borrow_usd)                                            AS borrow_volume_usd,
    ROUND(100.0 * SUM(wallet_borrow_usd)
          / SUM(SUM(wallet_borrow_usd)) OVER (), 2)                   AS volume_share_pct
FROM wallet_profile
GROUP BY 1, 2
ORDER BY protocol_count, borrowers DESC
