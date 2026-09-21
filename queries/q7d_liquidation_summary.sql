-- Q7d: liquidation summary per protocol for the whole period
-- Liquidation intensity = liquidated debt / borrow volume (activity indicator, not a default rate).
-- Reads saved results of Q7a; no rescan of the lending tables.
SELECT
    upper(substr(protocol, 1, 1)) || substr(protocol, 2)                  AS protocol,
    SUM(liquidation_events)                                                AS liquidations,
    SUM(debt_repaid_usd)                                                   AS liquidated_debt_usd,
    SUM(borrow_volume_usd)                                                 AS borrow_volume_usd,
    ROUND(100.0 * SUM(debt_repaid_usd) / SUM(borrow_volume_usd), 2)        AS intensity_pct,
    MAX(largest_event_usd)                                                 AS largest_event_usd
FROM query_8782771
GROUP BY 1
ORDER BY intensity_pct DESC
