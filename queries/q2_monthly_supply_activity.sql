-- Q2: monthly supply activity (deposits and withdrawals)
-- Ethereum, Aave / Compound / Morpho / Spark, 2026-01-01 to 2026-08-31.
-- Compound uses 'supply' where the other protocols use 'deposit'.
-- Withdrawal amounts are negative in the source, so ABS() is applied.

SELECT
    date_trunc('month', block_time)                       AS month,
    project                                               AS protocol,
    CASE
        WHEN transaction_type IN ('deposit', 'supply') THEN 'Deposit'
        WHEN transaction_type = 'withdraw'             THEN 'Withdraw'
    END                                                   AS activity,
    SUM(ABS(amount_usd))                                  AS volume_usd,
    COUNT(*)                                              AS events,
    COUNT(DISTINCT COALESCE(depositor, withdrawn_to))     AS unique_wallets,
    ROUND(SUM(ABS(amount_usd)) / NULLIF(COUNT(amount_usd), 0), 0) AS avg_ticket_usd
FROM lending.supply
WHERE blockchain = 'ethereum'
  AND project IN ('aave', 'compound', 'morpho', 'spark')
  AND transaction_type IN ('deposit', 'supply', 'withdraw')
  AND block_month >= TIMESTAMP '2026-01-01'
  AND block_month <  TIMESTAMP '2026-09-01'
  AND block_time  >= TIMESTAMP '2026-01-01'
  AND block_time  <  TIMESTAMP '2026-09-01'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
