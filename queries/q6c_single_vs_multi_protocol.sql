-- Q6c: chart helper for widget 6.1
-- Groups borrower wallets into single-protocol vs multi-protocol users.
-- Column names are human-readable because Dune uses them as legend labels.
-- Reads saved results of Q6; no rescan of the lending tables.
SELECT
    CASE WHEN protocol_count = 1 THEN 'Single protocol'
         ELSE 'Multiple protocols' END            AS wallet_group,
    ROUND(SUM(borrower_share_pct), 1)             AS "Wallets",
    ROUND(SUM(volume_share_pct), 1)               AS "Volume"
FROM query_8782614
GROUP BY 1
ORDER BY 1 DESC
