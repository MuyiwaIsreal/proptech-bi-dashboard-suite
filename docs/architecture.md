# Pipeline Architecture — Mage ETL + ERPNext + Power BI

## Overview
Self-hosted Mage pipeline running on company infrastructure, pulling from ERPNext
transactional tables and writing clean summary tables to the analytics database.

## Stack
| Layer | Technology |
|-------|-----------|
| ERP Source | ERPNext (self-hosted, all modules) |
| ETL Orchestration | Mage (self-hosted) |
| Analytics DB | PostgreSQL / MySQL |
| BI Layer | Power BI (Import mode) |
| Scheduling | Mage built-in scheduler |

## Pipeline Flows

```
ERPNext DB (source)
    │
    ├── GL Entry table ──────────────► [Mage: finance_pipeline]
    │                                       │
    ├── Salary Slip table ─────────► [Mage: hr_pipeline]
    │                                       │
    ├── Stock Ledger Entry ────────► [Mage: inventory_pipeline]
    │                                       │
    ├── Opportunity / Lead ───────► [Mage: crm_pipeline]
    │                                       │
    └── Multiple modules ─────────► [Mage: ops_kpi_pipeline]
                                           │
                                    Analytics DB (summary tables)
                                           │
                                    Power BI (Import + scheduled refresh)
                                           │
                                    Dashboards → Executives, Finance, Ops
```

## Pipeline Design Decisions

**Why Mage over cron + SQL scripts?**
Mage provides visual pipeline monitoring, retry logic, and failure alerts out of the box.
When a pipeline fails, the team gets notified rather than discovering stale data in dashboards.

**Why summary tables instead of DirectQuery?**
ERPNext production DB tables are large and optimised for transactions, not analytics.
DirectQuery would cause slow dashboards and added load on the ERP. Summary tables
decouple analytics performance from ERP performance entirely.

**Why Import mode in Power BI?**
Summary tables are small (post-aggregation) and refresh daily — making Import mode
both viable and faster for end users than DirectQuery or Live Connection.
