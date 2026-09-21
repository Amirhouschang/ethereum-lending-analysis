-- Q5: asset composition, deposit side and borrow side
-- Ethereum, Aave / Compound / Morpho / Spark, 2026-01-01 to 2026-08-31.
-- Top 5 tokens per protocol and side are kept, the rest is grouped as 'Other'
-- (5 instead of 6 because four protocols make the stacked bars narrower).

WITH deposits AS (
    SELECT
        project,
        'Deposit'            AS side,
        symbol,
        SUM(ABS(amount_usd)) AS volume_usd,
        COUNT(*)             AS events
    FROM lending.supply
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND transaction_type IN ('deposit', 'supply')
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
    GROUP BY 1, 2, 3
),

borrows AS (
    SELECT
        project,
        'Borrow'             AS side,
        symbol,
        SUM(ABS(amount_usd)) AS volume_usd,
        COUNT(*)             AS events
    FROM lending.borrow
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND transaction_type = 'borrow'
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
    GROUP BY 1, 2, 3
),

combined AS (
    SELECT * FROM deposits
    UNION ALL
    SELECT * FROM borrows
),

ranked AS (
    SELECT
        project,
        side,
        symbol,
        volume_usd,
        events,
        ROUND(100.0 * volume_usd
              / SUM(volume_usd) OVER (PARTITION BY project, side), 2) AS share_pct,
        ROW_NUMBER() OVER (PARTITION BY project, side
                           ORDER BY volume_usd DESC)                  AS rank_in_protocol
    FROM combined
    WHERE volume_usd IS NOT NULL
)

SELECT
    project AS protocol,
    side,
    symbol,
    CASE WHEN rank_in_protocol <= 5 THEN symbol ELSE 'Other' END AS symbol_grouped,
    volume_usd,
    events,
    share_pct,
    rank_in_protocol
FROM ranked
ORDER BY protocol, side, rank_in_protocol
