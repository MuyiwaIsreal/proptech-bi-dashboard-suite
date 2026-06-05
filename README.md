# PropTech BI Dashboard Suite — Power BI + ERPNext + Mage Pipeline

> **End-to-end business intelligence system built for a fast-growing PropTech SaaS company.**
> All company-specific data has been anonymised. Architecture, methodology, and outcomes are real.

---

## Project Overview

| | |
|---|---|
| **Role** | Data Intelligence & BI Analyst (sole BI owner) |
| **Industry** | PropTech SaaS — property & community management platform |
| **Tools** | Power BI · ERPNext · Mage (self-hosted) · PostgreSQL · MySQL · Python · SQL |
| **Dashboards built** | 40+ across 5 business domains |
| **Pipeline** | Self-hosted Mage ETL — multi-source ERP → summary tables → Power BI |
| **Stakeholders** | C-suite executives · Finance team · Operations & customer support |

---

## Problem Statement

The company operated a multi-module ERP system (ERPNext) generating large transactional tables across Finance, HR, Inventory, CRM, and Operations. Key challenges:

- **No centralised reporting** — each department extracted raw data manually into Excel and built their own ad-hoc reports
- **Slow queries** — BI tools querying large raw ERP tables directly caused performance issues and timeouts
- **No single source of truth** — different teams reported conflicting numbers from the same underlying data
- **Executive visibility gap** — leadership had no real-time view of business performance across departments

---

## Solution Architecture

```
┌─────────────────────────────────────────────┐
│              ERPNext (Self-hosted)           │
│  Accounts · HR · Inventory · CRM · Projects │
└───────────────────┬─────────────────────────┘
                    │  Raw transactional tables
                    ▼
┌─────────────────────────────────────────────┐
│         Mage Pipeline (Self-hosted ETL)      │
│  • Extracts from multiple ERPNext modules    │
│  • Transforms & aggregates into summary      │
│    tables optimised for BI consumption       │
│  • Scheduled batch processing                │
│  • Managed jointly with IT/dev team          │
└───────────────────┬─────────────────────────┘
                    │  Clean summary tables
                    ▼
┌─────────────────────────────────────────────┐
│         PostgreSQL / MySQL (Analytics DB)    │
│  Relational schema designed for analytical   │
│  query performance, not transaction speed    │
└───────────────────┬─────────────────────────┘
                    │  DirectQuery / Import
                    ▼
┌─────────────────────────────────────────────┐
│              Power BI (40+ Dashboards)       │
│  Finance · HR · Inventory · CRM · Ops KPIs  │
│  Served to: Executives · Finance · Ops teams │
└─────────────────────────────────────────────┘
```

---

## Mage Pipeline Design

### What it does
The self-hosted Mage pipeline was the core data engineering layer. Its job: take large, normalised ERPNext transactional tables and consolidate them into lean, pre-aggregated **summary tables** that Power BI can query quickly and reliably.

### Key pipeline patterns built

**1. Finance summary table**
- Source: ERPNext GL entries, payment ledger, invoice tables
- Output: Monthly P&L summary, revenue by category, outstanding receivables snapshot
- Aggregations: SUM by account head, period, cost centre

**2. HR & Payroll summary table**
- Source: ERPNext HR module — employee records, payroll entries, leave applications
- Output: Headcount by department, monthly payroll cost, leave utilisation summary
- Aggregations: COUNT by department/status, SUM payroll by month

**3. Inventory summary table**
- Source: ERPNext Stock Ledger entries, Purchase Orders, Sales Orders
- Output: Stock on hand by item/warehouse, turnover rates, low-stock alerts
- Aggregations: Running balance calculations, days-of-stock metrics

**4. CRM / Sales pipeline summary**
- Source: ERPNext CRM module — leads, opportunities, quotations, sales orders
- Output: Pipeline value by stage, conversion rates, sales cycle duration
- Aggregations: COUNT and SUM by stage, rep, period

**5. Operational KPI summary**
- Source: Multiple modules combined — customer support tickets, project tasks, delivery records
- Output: Response time metrics, task completion rates, SLA compliance
- Aggregations: AVG, percentile calculations, period-over-period change

### Pipeline management
- Scheduled batch runs (daily/weekly depending on table size and business need)
- Collaborated with IT/dev team on infrastructure, scheduling, and error handling
- Monitored pipeline health and resolved data refresh failures
- Documented table schemas and transformation logic for team knowledge transfer

---

## Power BI Dashboard Suite

### Dashboard 1 — Executive Financial Overview
**Audience:** C-suite / senior management
**Purpose:** Single-page view of company financial health

Key visuals:
- Monthly revenue vs target (bar + line combo)
- Expense breakdown by category (treemap)
- Gross margin trend (area chart)
- Outstanding receivables aging (stacked bar)
- P&L summary table with period comparison

DAX measures used:
```dax
Revenue MTD = 
CALCULATE(SUM(Finance_Summary[Revenue]), DATESMTD('Date'[Date]))

Revenue vs Target % = 
DIVIDE([Revenue MTD], [Monthly Target], 0)

Receivables Overdue 30d = 
CALCULATE(SUM(Finance_Summary[Outstanding]), Finance_Summary[Aging_Days] > 30)
```

---

### Dashboard 2 — HR & Workforce Analytics
**Audience:** Finance team, HR operations
**Purpose:** Headcount visibility, payroll cost tracking, leave management

Key visuals:
- Headcount by department (horizontal bar)
- Monthly payroll cost trend (line chart)
- Leave utilisation heatmap by month and department
- Employee tenure distribution (histogram)
- New hires vs attrition (waterfall chart)

---

### Dashboard 3 — Operational KPI Dashboard
**Audience:** Operations team, executives
**Purpose:** Real-time operational efficiency monitoring

Key visuals:
- KPI scorecard tiles (with RAG status — Red/Amber/Green)
- Response time trend vs SLA threshold
- Task completion rate by team
- Period-over-period efficiency change (%)
- Top bottlenecks by process area

Conditional formatting logic:
```dax
KPI Status = 
SWITCH(TRUE(),
    [Efficiency Rate] >= 0.90, "Green",
    [Efficiency Rate] >= 0.75, "Amber",
    "Red"
)
```

---

### Dashboard 4 — CRM & Sales Pipeline
**Audience:** Sales management, executives
**Purpose:** Pipeline visibility and conversion tracking

Key visuals:
- Pipeline funnel (by stage count and value)
- Win rate trend (line chart)
- Average sales cycle duration
- Revenue by customer segment (donut)
- Monthly closed deals vs target

---

## Data Modelling Approach

The relational schema in the analytics database was designed with BI performance in mind:

```
dim_date        ──┐
dim_department  ──┤
dim_employee    ──┤──► fact_payroll_monthly
dim_account     ──┤
                  │
dim_date        ──┤
dim_customer    ──┤──► fact_revenue_monthly
dim_product     ──┘

dim_date        ──┐
dim_item        ──┤──► fact_inventory_daily
dim_warehouse   ──┘
```

- Star schema pattern throughout for optimal Power BI performance
- Date dimension table with fiscal year, quarter, week number fields
- All foreign key relationships enforced in Power BI data model
- Calculated columns kept minimal — most logic pushed to DAX measures or SQL transformations in Mage

---

## Key Outcomes

| Metric | Before | After |
|--------|--------|-------|
| Manual reporting hours/week | ~5–8 hrs per department | ~1 hr (review only) |
| Data refresh frequency | Ad-hoc / weekly manual | Daily automated |
| Operational efficiency | Baseline | +20% improvement identified & tracked |
| Executive report turnaround | 2–3 days | Real-time dashboard |
| Reporting source conflicts | Frequent | Eliminated (single source of truth) |
| Dashboards available | 0 | 40+ |

---

## What I Learned

**Technical:**
- Designing ETL pipelines that balance transformation complexity with scheduling reliability
- When to use DirectQuery vs Import mode in Power BI (summary tables made Import mode viable)
- Star schema design for multi-module ERP data
- Writing DAX measures for time intelligence (MTD, YTD, period-over-period)

**Collaborative:**
- Working with IT/dev teams on pipeline infrastructure — communicating data requirements clearly
- Translating business questions from finance, HR, and ops teams into data model requirements
- Managing multiple stakeholder needs without compromising dashboard clarity

---

## Repository Structure

```
proptech-bi-dashboard-suite/
│
├── README.md                  ← This file
├── pipeline/
│   ├── finance_summary.sql    ← SQL transformation for finance summary table
│   ├── hr_summary.sql         ← HR & payroll aggregation logic
│   ├── inventory_summary.sql  ← Inventory stock summary
│   └── crm_summary.sql        ← CRM pipeline aggregation
│
├── powerbi/
│   ├── data_model.md          ← Star schema diagram and table relationships
│   ├── dax_measures.md        ← Key DAX measures used across dashboards
│   └── dashboard_screenshots/ ← Anonymised dashboard screenshots
│
└── docs/
    ├── architecture.md        ← Full pipeline architecture writeup
    └── lessons_learned.md     ← Reflections and what I'd do differently
```

---

## About the Author

**Ojo Muyiwa Isreal** — Data Intelligence & BI Analyst based in Lagos, Nigeria.
Open to fully remote data analyst roles globally.

- Portfolio: [muyiwaisreal.github.io](https://muyiwaisreal.github.io)
- LinkedIn: [linkedin.com/in/muyiwa-isreal-o](https://www.linkedin.com/in/muyiwa-isreal-o/)
- Email: muyiwaojo33@gmail.com

---

*Note: All business data, company names, and financial figures in this writeup have been anonymised or replaced with representative values for portfolio purposes.*
