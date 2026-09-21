-- Q0: data coverage and quality check
-- Ethereum lending activity, 2026-01-01 to 2026-08-31
-- Purpose: confirm exact project names, versions, transaction types and USD coverage
--          BEFORE any analysis query is written.

WITH supply_rows AS (
    SELECT
        'lending.supply'   AS source_table,
        project,
        version,
        transaction_type,
        amount_usd,
        block_time
    FROM lending.supply
    WHERE blockchain = 'ethereum'
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
),

borrow_rows AS (
    SELECT
        'lending.borrow'   AS source_table,
        project,
        version,
        transaction_type,
        amount_usd,
        block_time
    FROM lending.borrow
    WHERE blockchain = 'ethereum'
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
),

all_rows AS (
    SELECT * FROM supply_rows
    UNION ALL
    SELECT * FROM borrow_rows
)

SELECT
    source_table,
    project,
    version,
    transaction_type,
    COUNT(*)                                             AS events,
    COUNT(amount_usd)                                    AS events_with_usd,
    ROUND(100.0 * COUNT(amount_usd) / COUNT(*), 2)       AS usd_coverage_pct,
    ROUND(SUM(amount_usd) / 1e6, 2)                      AS volume_musd,
    MIN(block_time)                                      AS first_event,
    MAX(block_time)                                      AS last_event
FROM all_rows
GROUP BY 1, 2, 3, 4
ORDER BY project, source_table, transaction_type, version
