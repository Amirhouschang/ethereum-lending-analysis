-- Q3c: chart helper for widgets 3.1 and 3.2
-- One row per month and protocol, borrows and repayments side by side.
-- Reads saved results of Q3; no rescan of the lending tables.
SELECT
    month,
    upper(substr(protocol, 1, 1)) || substr(protocol, 2)          AS protocol,
    SUM(CASE WHEN activity = 'Borrow' THEN volume_usd END)        AS borrow_usd,
    SUM(CASE WHEN activity = 'Repay'  THEN volume_usd END)        AS repay_usd
FROM query_8782568
GROUP BY 1, 2
ORDER BY 1, 2
