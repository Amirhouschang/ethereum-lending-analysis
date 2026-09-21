-- Q7b: top liquidated assets per protocol, with the largest single event as proof
-- Ethereum, Aave / Compound / Morpho / Spark, 2026-01-01 to 2026-08-31.

WITH liquidations AS (
    SELECT
        project,
        symbol,
        ABS(amount_usd) AS amount_usd,
        tx_hash
    FROM lending.borrow
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND transaction_type = 'borrow_liquidation'
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
),

by_asset AS (
    SELECT
        project,
        symbol,
        SUM(amount_usd)             AS debt_repaid_usd,
        COUNT(*)                    AS liquidation_events,
        MAX(amount_usd)             AS largest_event_usd,
        MAX_BY(tx_hash, amount_usd) AS largest_event_tx
    FROM liquidations
    GROUP BY 1, 2
)

SELECT
    project AS protocol,
    symbol,
    debt_repaid_usd,
    liquidation_events,
    ROUND(100.0 * debt_repaid_usd
          / SUM(debt_repaid_usd) OVER (PARTITION BY project), 2) AS share_pct,
    largest_event_usd,
    largest_event_tx
FROM by_asset
ORDER BY protocol, debt_repaid_usd DESC
