-- Q5c: chart helper for widget 5.1
-- Borrow side only; tokens outside the top 5 per protocol are grouped as 'Other'.
-- Reads saved results of Q5; no rescan of the lending tables.
SELECT
    upper(substr(protocol, 1, 1)) || substr(protocol, 2)   AS protocol,
    symbol_grouped                                          AS token,
    SUM(share_pct)                                          AS share_pct
FROM query_8782601
WHERE side = 'Borrow'
GROUP BY 1, 2
ORDER BY 1, 3 DESC
