-- HR & Payroll Summary Table
-- Aggregates ERPNext HR module data for workforce analytics
-- Used by: Power BI HR & Workforce Dashboard
-- Refresh: Daily via Mage pipeline

CREATE TABLE IF NOT EXISTS headcount_summary AS
SELECT
    department,
    employment_type,
    status,
    COUNT(*)                                   AS headcount,
    AVG(EXTRACT(YEAR FROM AGE(date_of_joining))) AS avg_tenure_years,
    CURRENT_TIMESTAMP                          AS refreshed_at
FROM employee
WHERE status IN ('Active', 'Left')
GROUP BY 1, 2, 3;

-- Monthly payroll cost summary
CREATE TABLE IF NOT EXISTS payroll_monthly AS
SELECT
    DATE_TRUNC('month', start_date)            AS payroll_month,
    department,
    SUM(gross_pay)                             AS total_gross,
    SUM(total_deduction)                       AS total_deductions,
    SUM(net_pay)                               AS total_net,
    COUNT(DISTINCT employee)                   AS employee_count
FROM salary_slip
WHERE docstatus = 1
GROUP BY 1, 2;

-- Leave utilisation summary
CREATE TABLE IF NOT EXISTS leave_summary AS
SELECT
    DATE_TRUNC('month', from_date)             AS leave_month,
    department,
    leave_type,
    SUM(total_leave_days)                      AS days_taken,
    COUNT(DISTINCT employee)                   AS employees_on_leave
FROM leave_application
WHERE status = 'Approved'
  AND docstatus = 1
GROUP BY 1, 2, 3;
