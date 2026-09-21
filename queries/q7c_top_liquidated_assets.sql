-- Q7c: dashboard helper for widget 7.3
-- Top 5 liquidated tokens per protocol, by liquidated debt.
-- Reads saved results of Q7b; no rescan of the lending tables.
SELECT
    upper(substr(protocol, 1, 1)) || substr(protocol, 2)   AS protocol,
    symbol                                                  AS token,
    debt_repaid_usd,
    liquidation_events,
    share_pct,
    largest_event_usd,
    largest_event_tx
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY protocol
                           ORDER BY debt_repaid_usd DESC) AS rn
    FROM query_8782774
)
WHERE rn <= 5
    AND debt_repaid_usd >= 10000
ORDER BY protocol, debt_repaid_usd DESC
