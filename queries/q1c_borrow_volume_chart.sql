-- Q1c: chart helper for widget 1.5
-- One column per protocol so each bar can get its own colour in Dune.
-- The label carries the value because Dune hides data labels on stacked bars.
-- Reads saved results of Q1; no rescan of the lending tables.
SELECT
    upper(substr(protocol, 1, 1)) || substr(protocol, 2)
        || '  ·  $' || format('%.1f', borrow_usd / 1e9) || 'B'   AS protocol_label,
    borrow_usd,
    CASE WHEN protocol = 'aave'     THEN borrow_usd END             AS aave,
    CASE WHEN protocol = 'spark'    THEN borrow_usd END             AS spark,
    CASE WHEN protocol = 'morpho'   THEN borrow_usd END             AS morpho,
    CASE WHEN protocol = 'compound' THEN borrow_usd END             AS compound
FROM query_8782494
ORDER BY borrow_usd DESC
