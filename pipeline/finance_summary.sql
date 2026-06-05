-- Finance Summary Table
-- Transforms raw ERPNext GL entries into a monthly P&L summary
-- Used by: Power BI Financial Overview Dashboard
-- Refresh: Daily via Mage pipeline

CREATE TABLE IF NOT EXISTS finance_summary AS
SELECT
    DATE_TRUNC('month', posting_date)          AS month,
    account_head,
    cost_center,
    SUM(debit)                                 AS total_debit,
    SUM(credit)                                AS total_credit,
    SUM(credit - debit)                        AS net_amount,
    COUNT(*)                                   AS transaction_count,
    CURRENT_TIMESTAMP                          AS refreshed_at
FROM gl_entry
WHERE is_cancelled = 0
GROUP BY 1, 2, 3;

-- Revenue summary (credit-side accounts)
CREATE TABLE IF NOT EXISTS revenue_monthly AS
SELECT
    DATE_TRUNC('month', posting_date)          AS month,
    account_head,
    SUM(credit - debit)                        AS revenue,
    COUNT(DISTINCT party)                      AS unique_customers
FROM gl_entry
WHERE account_type IN ('Income Account', 'Revenue')
  AND is_cancelled = 0
GROUP BY 1, 2;

-- Outstanding receivables
CREATE TABLE IF NOT EXISTS receivables_aging AS
SELECT
    customer,
    invoice_number,
    outstanding_amount,
    due_date,
    CURRENT_DATE - due_date                    AS aging_days,
    CASE
        WHEN CURRENT_DATE - due_date <= 0  THEN 'Current'
        WHEN CURRENT_DATE - due_date <= 30 THEN '1-30 days'
        WHEN CURRENT_DATE - due_date <= 60 THEN '31-60 days'
        ELSE '60+ days'
    END                                        AS aging_bucket
FROM sales_invoice
WHERE outstanding_amount > 0
  AND docstatus = 1;
