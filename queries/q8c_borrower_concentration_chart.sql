-- Q8c: chart helper for widget 8.2
-- Share of borrow volume from the 10 and 100 largest wallets per protocol.
-- Column names are human-readable because Dune uses them as legend labels.
-- Reads saved results of Q8; no rescan of the lending tables.
SELECT
    upper(substr(protocol, 1, 1)) || substr(protocol, 2)   AS protocol,
    top10_share_pct                                         AS "Top 10",
    top100_share_pct                                        AS "Top 100"
FROM query_8782781
ORDER BY top10_share_pct DESC
