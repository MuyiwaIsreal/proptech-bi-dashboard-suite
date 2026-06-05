-- Inventory & Supply Chain Summary Table
-- Transforms ERPNext Stock Ledger into analytics-ready summaries
-- Used by: Power BI Inventory Dashboard
-- Refresh: Daily via Mage pipeline

CREATE TABLE IF NOT EXISTS stock_on_hand AS
SELECT
    item_code,
    item_name,
    item_group,
    warehouse,
    SUM(actual_qty)                            AS qty_on_hand,
    AVG(valuation_rate)                        AS avg_valuation_rate,
    SUM(actual_qty * valuation_rate)           AS stock_value,
    CURRENT_TIMESTAMP                          AS refreshed_at
FROM bin
GROUP BY 1, 2, 3, 4;

-- Stock movement summary
CREATE TABLE IF NOT EXISTS stock_movement_monthly AS
SELECT
    DATE_TRUNC('month', posting_date)          AS month,
    item_code,
    item_name,
    warehouse,
    SUM(CASE WHEN actual_qty > 0 THEN actual_qty ELSE 0 END)  AS qty_in,
    SUM(CASE WHEN actual_qty < 0 THEN ABS(actual_qty) ELSE 0 END) AS qty_out
FROM stock_ledger_entry
WHERE is_cancelled = 0
GROUP BY 1, 2, 3, 4;
