# 05. SLA Attainment

Scoring results against goals when some metrics are "higher is better" (fill rate, accuracy) and others are "lower is better" (days to fill). Each row in `FactSLA` carries its own goal and a `HigherIsBetter` flag, so one set of measures handles all of them.

## Result and goal

```dax
SLA Result = AVERAGE ( FactSLA[Result] )

SLA Goal = AVERAGE ( FactSLA[Goal] )
```

These work when a visual shows one metric at a time. Averaging a percentage across programs is a simplification. If volumes differ a lot between programs, carry a numerator and denominator in the fact table and use a weighted ratio instead.

## Status for a single metric

```dax
SLA Status =
VAR Result = [SLA Result]
VAR Goal = [SLA Goal]
VAR HigherBetter = SELECTEDVALUE ( FactSLA[HigherIsBetter] )
VAR Tolerance = 0.05 -- within 5% of goal counts as "Near"
VAR Gap =
    IF (
        HigherBetter,
        DIVIDE ( Result - Goal, Goal ),
        DIVIDE ( Goal - Result, Goal )
    )
RETURN
    IF (
        ISBLANK ( Result ) || ISBLANK ( Goal ),
        "No data",
        IF (
            ISBLANK ( HigherBetter ),
            "Select a metric",
            IF ( Gap >= 0, "Met", IF ( Gap >= -Tolerance, "Near", "Missed" ) )
        )
    )
```

`SELECTEDVALUE` returns blank when the selection mixes higher-is-better and lower-is-better metrics, which is why the measure asks for a single metric instead of guessing.

## Attainment across many metrics

Score each row against its own goal, then count. This works when a visual mixes metrics.

```dax
SLA Met Count =
SUMX (
    FactSLA,
    VAR Hit =
        IF (
            FactSLA[HigherIsBetter],
            FactSLA[Result] >= FactSLA[Goal],
            FactSLA[Result] <= FactSLA[Goal]
        )
    RETURN
        IF ( Hit, 1, 0 )
)

SLA Reported Count = COUNTROWS ( FactSLA )

SLA Attainment % = DIVIDE ( [SLA Met Count], [SLA Reported Count] )
```

The result reads as "percent of reported results that met their goal."

## Display format per metric

Percent metrics and day metrics need different formats on the same measure. In recent versions of Power BI Desktop, set a dynamic format string on `SLA Result`:

```dax
IF (
    SELECTEDVALUE ( FactSLA[Metric] ) = "Time to Fill (days)",
    "0.0",
    "0.0%"
)
```

## Mixed reporting grain

If some metrics are reported monthly and others quarterly, store each result at its natural grain, with the first day of the period in the date column (the first day of the quarter for quarterly metrics). Show a quarterly metric only at quarter level or above, and warn in the visual title if someone drills below it.

## Common problems

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Many-to-many warning on the relationship | `FactSLA[Month]` is not always a first-of-month date | Convert with `Date.StartOfMonth` in Power Query |
| Status says "Select a metric" | Visual mixes higher-is-better and lower-is-better metrics | Filter to one metric, or use the attainment count pattern |
| Averages of percentages look off | Programs have very different volumes | Use a weighted ratio from numerator and denominator columns |
| Lower-is-better metric shows as "Missed" when below goal | Direction ignored | Check the `HigherIsBetter` flag in the data |
