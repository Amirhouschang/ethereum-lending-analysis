-- Q1k: headline KPIs for the dashboard counters
-- Reads saved results of Q1 and Q6; no rescan of the lending tables.
-- Values are pre-scaled for the counters: billions (bn) and millions (mn).
SELECT
    ROUND((SELECT SUM(deposit_usd)         FROM query_8782494) / 1e9, 1) AS total_deposit_usd_bn,
    ROUND((SELECT SUM(borrow_usd)          FROM query_8782494) / 1e9, 1) AS total_borrow_usd_bn,
    (SELECT SUM(borrowers)                 FROM query_8782614)           AS unique_borrowers_all_protocols,
    ROUND((SELECT SUM(debt_liquidated_usd) FROM query_8782494) / 1e6, 1) AS total_liquidated_debt_usd_mn
