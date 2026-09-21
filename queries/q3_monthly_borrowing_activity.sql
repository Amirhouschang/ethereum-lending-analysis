-- Q3: monthly borrowing activity (borrows and repayments)
-- Ethereum, Aave / Compound / Morpho / Spark, 2026-01-01 to 2026-08-31.
-- 'borrow_liquidation' rows are excluded here and analysed in Q7a / Q7b.
-- Repayment amounts are negative in the source, so ABS() is applied.

SELECT
    date_trunc('month', block_time)                       AS month,
    project                                               AS protocol,
    CASE transaction_type
        WHEN 'borrow' THEN 'Borrow'
        WHEN 'repay'  THEN 'Repay'
    END                                                   AS activity,
    SUM(ABS(amount_usd))                                  AS volume_usd,
    COUNT(*)                                              AS events,
    COUNT(DISTINCT COALESCE(borrower, repayer))           AS unique_wallets,
    ROUND(SUM(ABS(amount_usd)) / NULLIF(COUNT(amount_usd), 0), 0) AS avg_ticket_usd
FROM lending.borrow
WHERE blockchain = 'ethereum'
  AND project IN ('aave', 'compound', 'morpho', 'spark')
  AND transaction_type IN ('borrow', 'repay')
  AND block_month >= TIMESTAMP '2026-01-01'
  AND block_month <  TIMESTAMP '2026-09-01'
  AND block_time  >= TIMESTAMP '2026-01-01'
  AND block_time  <  TIMESTAMP '2026-09-01'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
