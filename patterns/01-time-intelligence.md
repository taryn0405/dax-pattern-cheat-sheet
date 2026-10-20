# 01. Time Intelligence

Patterns for year-to-date, prior period, and rolling windows, including fiscal calendars.

**Requirements:** a contiguous date table (`DimDate`) marked as a date table, related to the fact table on the date column. Time intelligence functions should always use the date table's `Date` column, never the fact table's date.

## Base measures

Every pattern below builds on these.

```dax
Total Amount = SUM ( FactInvoices[Amount] )

Invoice Count = COUNTROWS ( FactInvoices )

Average Invoice = DIVIDE ( [Total Amount], [Invoice Count] )

Latest Data Date =
CALCULATE ( MAX ( FactInvoices[Date] ), ALL ( FactInvoices ) )
```

`Latest Data Date` anchors reports to the last date that has data instead of `TODAY()`, so a dashboard does not show empty trailing periods.

## Year to date

```dax
Calendar YTD Amount =
TOTALYTD ( [Total Amount], DimDate[Date] )

Fiscal YTD Amount =
TOTALYTD ( [Total Amount], DimDate[Date], "9/30" )
```

The third argument is the fiscal year end date as text (month/day). With an October fiscal start, the year ends September 30.

## Prior year and growth

```dax
Amount PY =
CALCULATE ( [Total Amount], SAMEPERIODLASTYEAR ( DimDate[Date] ) )

Amount YoY % =
DIVIDE ( [Total Amount] - [Amount PY], [Amount PY] )

Fiscal YTD Amount PY =
CALCULATE ( [Fiscal YTD Amount], SAMEPERIODLASTYEAR ( DimDate[Date] ) )
```

`DIVIDE` returns blank when the prior year is zero or blank, which avoids divide-by-zero errors.

## Rolling windows

```dax
Rolling 3 Months =
CALCULATE (
    [Total Amount],
    DATESINPERIOD ( DimDate[Date], MAX ( DimDate[Date] ), -3, MONTH )
)

Trailing 12 Months (from latest data) =
CALCULATE (
    [Total Amount],
    DATESINPERIOD ( DimDate[Date], [Latest Data Date], -12, MONTH )
)
```

The first window moves with the visual (each month shows its own trailing 3 months). The second ignores the visual's dates and always ends at the latest data date. Filters on other `DimDate` columns, such as a Fiscal Year slicer, still apply to both.

## Rolling fiscal quarters

`DATESINPERIOD` with `QUARTER` uses calendar quarters. For fiscal quarters, use an index column. `DimDate` includes `Fiscal Quarter Index` (`Fiscal Year * 4 + Fiscal Quarter`) for this.

```dax
Rolling 4 Fiscal Quarters =
VAR CurrentIndex = MAX ( DimDate[Fiscal Quarter Index] )
RETURN
    CALCULATE (
        [Total Amount],
        FILTER (
            ALL ( DimDate ),
            DimDate[Fiscal Quarter Index] > CurrentIndex - 4
                && DimDate[Fiscal Quarter Index] <= CurrentIndex
        )
    )
```

## Common problems

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| YTD or prior year returns blank | Date table has gaps or is not marked | Use a contiguous calendar and mark it as a date table |
| Totals look wrong by year | Used the fact table's date column inside the time function | Reference `DimDate[Date]` |
| Fiscal YTD resets in January | Used `TOTALYTD` without the year end argument | Add `"9/30"` (or your year end) |
| Rolling window includes extra months | Window anchored to the wrong date | Use `MAX ( DimDate[Date] )` for visual-relative, `[Latest Data Date]` for fixed |
