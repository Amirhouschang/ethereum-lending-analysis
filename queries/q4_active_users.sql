-- Q4: monthly active wallets per protocol
-- Ethereum, Aave / Compound / Morpho / Spark, 2026-01-01 to 2026-08-31.
-- A wallet counts as active in a month if it deposited (or supplied) or borrowed.

WITH depositors AS (
    SELECT
        date_trunc('month', block_time) AS month,
        project,
        depositor                       AS wallet,
        'depositor'                     AS role
    FROM lending.supply
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND transaction_type IN ('deposit', 'supply')
      AND depositor IS NOT NULL
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
),

borrowers AS (
    SELECT
        date_trunc('month', block_time) AS month,
        project,
        borrower                        AS wallet,
        'borrower'                      AS role
    FROM lending.borrow
    WHERE blockchain = 'ethereum'
      AND project IN ('aave', 'compound', 'morpho', 'spark')
      AND transaction_type = 'borrow'
      AND borrower IS NOT NULL
      AND block_month >= TIMESTAMP '2026-01-01'
      AND block_month <  TIMESTAMP '2026-09-01'
      AND block_time  >= TIMESTAMP '2026-01-01'
      AND block_time  <  TIMESTAMP '2026-09-01'
),

activity AS (
    SELECT * FROM depositors
    UNION ALL
    SELECT * FROM borrowers
)

SELECT
    month,
    project                                                          AS protocol,
    COUNT(DISTINCT CASE WHEN role = 'depositor' THEN wallet END)     AS active_depositors,
    COUNT(DISTINCT CASE WHEN role = 'borrower'  THEN wallet END)     AS active_borrowers,
    COUNT(DISTINCT wallet)                                           AS active_wallets_total
FROM activity
GROUP BY 1, 2
ORDER BY 1, 2
