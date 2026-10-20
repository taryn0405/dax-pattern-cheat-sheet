<h1 align="center">DAX Pattern Cheat Sheet</h1>

<p align="center">
  Practical DAX patterns for time intelligence, disconnected tables,
  conditional formatting, null handling, and SLA scoring, with mock data you can load in minutes.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/DAX-Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black" alt="DAX" />
  <img src="https://img.shields.io/badge/Data-100%25%20Mock-2EA44F?style=for-the-badge" alt="Mock data only" />
</p>

---

<!-- After you test the patterns, add a line here such as:
> **Tested:** patterns were tested in Power BI Desktop (month year) against the mock data in this repo.
-->

## Patterns

| Page | What it covers |
| --- | --- |
| [01. Time Intelligence](patterns/01-time-intelligence.md) | YTD, prior year, rolling windows, fiscal calendars |
| [02. Disconnected Tables](patterns/02-disconnected-tables.md) | Metric and period selectors driven by slicers |
| [03. Conditional Formatting](patterns/03-conditional-formatting.md) | Colors and icons driven by measures |
| [04. Nulls and Safe Math](patterns/04-nulls-and-safe-math.md) | `DIVIDE`, blank behavior, zero-filling without false zeros |
| [05. SLA Attainment](patterns/05-sla-attainment.md) | Scoring higher-is-better and lower-is-better goals together |
| [06. Debugging](patterns/06-debugging.md) | Circular dependencies, type problems, date filtering, grain mismatches |

Each page gives the measure, a short explanation, and a table of common problems and fixes.

## Set Up the Mock Data

1. In Power BI Desktop, open **Transform data**.
2. For each file in [`mock-data`](mock-data), create a **Blank Query**, open the **Advanced Editor**, paste the file contents, and rename the query to match the file name:
   - `FactInvoices`
   - `DimDate`
   - `FactSLA`
3. Click **Close & Apply**.
4. In **Model view**, create these relationships (one-to-many, single direction):
   - `DimDate[Date]` to `FactInvoices[Date]`
   - `DimDate[Date]` to `FactSLA[Month]`
5. Select `DimDate`, then **Table tools > Mark as date table**, using the `Date` column.
6. Sort `DimDate[Month Label]` by `Month Sort`.

## The Model

```
DimDate (Date) 1 ----< * FactInvoices (Date)
DimDate (Date) 1 ----< * FactSLA (Month)
```

| Table | Rows | Notes |
| --- | --- | --- |
| `FactInvoices` | 120 | Invoices across 3 programs and 4 vendors, Oct 2024 to Sep 2026 |
| `FactSLA` | 216 | Monthly results for 3 metrics, each with its own goal and direction |
| `DimDate` | about 820 | Daily calendar with an October fiscal year start |

## Conventions

- **Fiscal year naming:** the fiscal year is named for the calendar year in which it ends (Oct 2025 to Sep 2026 is FY2026).
- **Measure names:** plain English, with a suffix for variants (`PY`, `YTD`).
- **Reference measures, not columns, in other measures** so that filter context stays predictable.

## About the Data

All data in this repository is fabricated. No client, employer, or production data is included.

## Author

**Taryn Ledford**
[LinkedIn](https://www.linkedin.com/in/taryn-ledford)
