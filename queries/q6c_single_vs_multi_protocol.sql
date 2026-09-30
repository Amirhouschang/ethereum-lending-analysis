-- Q6c: chart helper for widget 6.1
-- Groups borrower wallets into single-protocol vs multi-protocol users.
-- Column names are human-readable because Dune uses them as legend labels.
-- Shares are computed from the raw counts and volumes of Q6, not from its already rounded percentages.
-- Reads saved results of Q6; no rescan of the lending tables.
SELECT
    CASE WHEN protocol_count = 1 THEN 'Single protocol'
         ELSE 'Multiple protocols' END                                              AS wallet_group,
    ROUND(100.0 * SUM(borrowers)         / SUM(SUM(borrowers))         OVER (), 1) AS "Wallets",
    ROUND(100.0 * SUM(borrow_volume_usd) / SUM(SUM(borrow_volume_usd)) OVER (), 1) AS "Volume"
FROM query_8782614
GROUP BY 1
ORDER BY 1 DESC
