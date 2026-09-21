-- Q7a: monthly liquidation activity
-- Borrow-side liquidations = debt repaid by liquidators.
-- Q0 finding: the value is 'borrow_liquidation', not 'liquidation'.
-- Supply-side liquidations ('deposit_liquidation' / 'supply_liquidation') are the
-- other leg of the same event and are deliberately NOT added to these figures.

WITH liquidations AS (
    SELECT
        date_trunc('month', block_time) AS month,
        project,
        borrower,
        liquidator,
        ABS(amount_usd)                 AS amount_usd
    FROM lending.borrow
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND transaction_type = 'borrow_liquidation'
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
),

borrow_volume AS (
    SELECT
        date_trunc('month', block_time) AS month,
        project,
        SUM(ABS(amount_usd))            AS borrow_volume_usd
    FROM lending.borrow
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND transaction_type = 'borrow'
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
    GROUP BY 1, 2
),

liquidation_stats AS (
    SELECT
        month,
        project,
        SUM(amount_usd)              AS debt_repaid_usd,
        COUNT(*)                     AS liquidation_events,
        COUNT(DISTINCT borrower)     AS liquidated_borrowers,
        COUNT(DISTINCT liquidator)   AS unique_liquidators,
        MAX(amount_usd)              AS largest_event_usd
    FROM liquidations
    GROUP BY 1, 2
)

SELECT
    l.month,
    l.project                                                        AS protocol,
    l.debt_repaid_usd,
    l.liquidation_events,
    l.liquidated_borrowers,
    l.unique_liquidators,
    l.largest_event_usd,
    b.borrow_volume_usd,
    ROUND(100.0 * l.debt_repaid_usd / NULLIF(b.borrow_volume_usd, 0), 2)
                                                                     AS liquidation_intensity_pct
FROM liquidation_stats l
LEFT JOIN borrow_volume b
       ON l.month = b.month
      AND l.project = b.project
ORDER BY l.month, l.project
