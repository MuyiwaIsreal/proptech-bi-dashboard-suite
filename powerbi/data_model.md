# Power BI Data Model — Star Schema Design

## Overview
All dashboards share a common star schema built on top of the Mage summary tables.
Fact tables are pre-aggregated — no raw ERP tables are queried directly by Power BI.

## Schema

```
dim_date ──────────────────────────────────┐
  date (PK)                                │
  year, quarter, month, week_number        ├──► fact_finance_monthly
  month_name, day_of_week, is_weekend      │      month (FK → dim_date)
  fiscal_year, fiscal_quarter              │      account_head (FK → dim_account)
                                           │      cost_center (FK → dim_department)
dim_department ────────────────────────────┤      revenue, expenses, net_amount
  department_id (PK)                       │
  department_name, cost_center             ├──► fact_payroll_monthly
  head_of_department                       │      payroll_month (FK → dim_date)
                                           │      department_id (FK → dim_department)
dim_employee ──────────────────────────────┤      total_gross, total_net
  employee_id (PK)                         │
  name, department_id (FK)                 ├──► fact_inventory_daily
  employment_type, date_of_joining         │      snapshot_date (FK → dim_date)
  status                                   │      item_code (FK → dim_item)
                                           │      warehouse (FK → dim_warehouse)
dim_item ──────────────────────────────────┤      qty_on_hand, stock_value
  item_code (PK)                           │
  item_name, item_group                    └──► fact_crm_monthly
  unit_of_measure                                month (FK → dim_date)
                                                 stage, deal_count, pipeline_value
dim_account ───────────────────────────────►
  account_head (PK)
  account_type, parent_account
  is_revenue, is_expense
```

## Relationships
- All fact tables connect to `dim_date` on their date key (many-to-one)
- Cross-filtering is single direction (dim → fact) to avoid ambiguity
- `dim_department` used by both Finance and HR facts
- Inactive relationships activated in DAX with USERELATIONSHIP() where needed

## Import vs DirectQuery
- **Import mode** used for all tables (summary tables are small enough)
- Scheduled refresh: daily at 06:00 WAT
- Data gateway: not required (summary tables hosted on same network as Power BI service)
