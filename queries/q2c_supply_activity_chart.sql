-- Q2c: chart helper for widgets 2.1 and 2.2
-- One row per month and protocol, deposits and withdrawals side by side.
-- Reads saved results of Q2; no rescan of the lending tables.
SELECT
    month,
    upper(substr(protocol, 1, 1)) || substr(protocol, 2)          AS protocol,
    SUM(CASE WHEN activity = 'Deposit'  THEN volume_usd END)      AS deposit_usd,
    SUM(CASE WHEN activity = 'Withdraw' THEN volume_usd END)      AS withdraw_usd
FROM query_8782537
GROUP BY 1, 2
ORDER BY 1, 2
