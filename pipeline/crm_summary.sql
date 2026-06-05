-- CRM & Sales Pipeline Summary Table
-- Aggregates ERPNext CRM module for pipeline analytics
-- Used by: Power BI CRM & Sales Dashboard
-- Refresh: Daily via Mage pipeline

CREATE TABLE IF NOT EXISTS sales_pipeline_summary AS
SELECT
    DATE_TRUNC('month', transaction_date)      AS month,
    status,
    opportunity_type,
    COUNT(*)                                   AS deal_count,
    SUM(opportunity_amount)                    AS pipeline_value,
    AVG(EXTRACT(DAY FROM AGE(COALESCE(modified, CURRENT_DATE), creation))) AS avg_days_in_stage
FROM opportunity
WHERE docstatus < 2
GROUP BY 1, 2, 3;

-- Conversion funnel
CREATE TABLE IF NOT EXISTS conversion_funnel AS
SELECT
    DATE_TRUNC('month', creation)              AS month,
    COUNT(DISTINCT CASE WHEN doctype='Lead' THEN name END)        AS leads,
    COUNT(DISTINCT CASE WHEN doctype='Opportunity' THEN name END) AS opportunities,
    COUNT(DISTINCT CASE WHEN doctype='Quotation' THEN name END)   AS quotations,
    COUNT(DISTINCT CASE WHEN doctype='Sales Order' THEN name END) AS orders
FROM (
    SELECT 'Lead' AS doctype, name, creation FROM crm_lead
    UNION ALL
    SELECT 'Opportunity', name, creation FROM opportunity
    UNION ALL
    SELECT 'Quotation', name, creation FROM quotation
    UNION ALL
    SELECT 'Sales Order', name, creation FROM sales_order
) funnel
GROUP BY 1;
