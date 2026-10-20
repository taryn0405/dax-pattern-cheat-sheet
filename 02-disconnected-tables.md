# 02. Disconnected Tables

A disconnected table has no relationships to the rest of the model. It exists only to feed a slicer, and a measure reads the selection. Use it to let people switch metrics, periods, or views without building separate visuals.

## Metric selector

Create the table (Modeling > New table):

```dax
Metric Selector =
DATATABLE (
    "Metric", STRING,
    "Order", INTEGER,
    {
        { "Amount", 1 },
        { "Invoice Count", 2 },
        { "Average Invoice", 3 }
    }
)
```

Set `Metric` to sort by `Order` (Column tools > Sort by column). Do not create any relationships for this table.

Then a measure that responds to the slicer:

```dax
Selected Metric Value =
SWITCH (
    SELECTEDVALUE ( 'Metric Selector'[Metric], "Amount" ),
    "Amount", [Total Amount],
    "Invoice Count", [Invoice Count],
    "Average Invoice", [Average Invoice],
    BLANK ()
)
```

Add `Metric` to a slicer and `Selected Metric Value` to a chart. The second argument of `SELECTEDVALUE` is the default when nothing, or more than one item, is selected.

## Period selector

```dax
Period Selector =
DATATABLE (
    "Period", STRING,
    "Order", INTEGER,
    {
        { "Month", 1 },
        { "Fiscal YTD", 2 },
        { "Trailing 12 Months", 3 }
    }
)
```

```dax
Amount by Selected Period =
SWITCH (
    SELECTEDVALUE ( 'Period Selector'[Period], "Month" ),
    "Month", [Total Amount],
    "Fiscal YTD", [Fiscal YTD Amount],
    "Trailing 12 Months", [Trailing 12 Months (from latest data)],
    BLANK ()
)
```

This uses the measures from `01-time-intelligence.md`.

## Formatting a mixed-unit measure

When one measure returns currency for one choice and a count for another, avoid wrapping the result in `FORMAT()`. It returns text, which breaks sorting and chart axes. In recent versions of Power BI Desktop, use a dynamic format string on the measure instead:

```dax
IF (
    SELECTEDVALUE ( 'Metric Selector'[Metric] ) = "Invoice Count",
    "#,0",
    "$#,0.00"
)
```

## Common problems

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Slicer changes nothing | Measure does not read the selector table | Use `SELECTEDVALUE` or `VALUES` on the selector column |
| Always shows the default | Multiple items selected, or none | Set the slicer to single select, or handle the multi-select case in the measure |
| Selector options sort alphabetically | No sort order set | Sort the label column by the `Order` column |
| Selector filters the other tables | A relationship was created by accident | Delete it so the table stays disconnected |
