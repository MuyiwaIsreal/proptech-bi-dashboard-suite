# Key DAX Measures — PropTech BI Dashboard Suite

## Finance Dashboard

```dax
-- Revenue Month-to-Date
Revenue MTD =
CALCULATE(SUM(finance_summary[net_amount]), DATESMTD('Date'[Date]))

-- Revenue Year-to-Date
Revenue YTD =
CALCULATE(SUM(finance_summary[net_amount]), DATESYTD('Date'[Date]))

-- Revenue vs Prior Month
Revenue MoM % =
VAR CurrentMonth = [Revenue MTD]
VAR PriorMonth   = CALCULATE([Revenue MTD], DATEADD('Date'[Date], -1, MONTH))
RETURN DIVIDE(CurrentMonth - PriorMonth, PriorMonth, 0)

-- Receivables overdue 30+ days
Receivables Overdue 30d =
CALCULATE(SUM(receivables_aging[outstanding_amount]),
    receivables_aging[aging_days] > 30)
```

## HR Dashboard

```dax
-- Active headcount
Active Headcount =
CALCULATE(COUNT(headcount_summary[employee_id]),
    headcount_summary[status] = "Active")

-- Monthly payroll cost
Payroll Cost MTD =
CALCULATE(SUM(payroll_monthly[total_net]), DATESMTD('Date'[Date]))

-- Attrition rate
Attrition Rate =
DIVIDE(
    CALCULATE(COUNT(headcount_summary[employee_id]),
        headcount_summary[status] = "Left"),
    [Active Headcount], 0)
```

## Operations Dashboard

```dax
-- KPI status (RAG)
KPI Status =
SWITCH(TRUE(),
    [Efficiency Rate] >= 0.90, "Green",
    [Efficiency Rate] >= 0.75, "Amber",
    "Red")

-- Period-over-period efficiency change
Efficiency Change % =
VAR Current = [Efficiency Rate]
VAR Prior   = CALCULATE([Efficiency Rate], DATEADD('Date'[Date], -1, MONTH))
RETURN DIVIDE(Current - Prior, Prior, 0)
```

## CRM Dashboard

```dax
-- Pipeline value
Pipeline Value =
CALCULATE(SUM(sales_pipeline_summary[pipeline_value]),
    sales_pipeline_summary[status] <> "Lost")

-- Win rate
Win Rate =
DIVIDE(
    CALCULATE(COUNT(sales_pipeline_summary[deal_count]),
        sales_pipeline_summary[status] = "Won"),
    COUNT(sales_pipeline_summary[deal_count]), 0)

-- Average sales cycle (days)
Avg Sales Cycle Days =
AVERAGE(sales_pipeline_summary[avg_days_in_stage])
```
