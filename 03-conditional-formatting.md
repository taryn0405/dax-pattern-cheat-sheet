# 03. Conditional Formatting

Drive colors and icons from measures instead of hardcoding rules in the visual. The logic lives in one place, is easy to test, and works the same across tables, matrices, and cards.

These patterns use the status measure defined in `05-sla-attainment.md`.

## Color from a measure

```dax
Status Color =
SWITCH (
    [SLA Status],
    "Met", "#2E7D32",
    "Near", "#F9A825",
    "Missed", "#C62828",
    "#9E9E9E"
)
```

To apply it, select the visual, open Format, find the column or value, then Background color (or Font color) > fx. Set Format style to **Field value** and choose `Status Color`. The last line of the measure is the fallback (gray) for rows with no data.

Menu names can shift slightly between Desktop versions.

## Icons from a numeric code

```dax
Status Code =
SWITCH (
    [SLA Status],
    "Met", 1,
    "Near", 0,
    "Missed", -1,
    BLANK ()
)
```

Under Cell elements, turn on Icons for the measure, choose Format style **Rules**, and set:

| Rule | Icon |
| --- | --- |
| Value >= 1 | Green check or circle |
| Value = 0 | Yellow warning |
| Value <= -1 | Red cross |

Use a numeric code for icons and a text status for labels. Icon rules compare numbers, so a text measure will not work there.

## Gradient by gap to goal

```dax
Gap to Goal % =
VAR HigherBetter = SELECTEDVALUE ( FactSLA[HigherIsBetter] )
RETURN
    IF (
        ISBLANK ( HigherBetter ),
        BLANK (),
        IF (
            HigherBetter,
            DIVIDE ( [SLA Result] - [SLA Goal], [SLA Goal] ),
            DIVIDE ( [SLA Goal] - [SLA Result], [SLA Goal] )
        )
    )
```

Positive means better than goal for both "higher is better" and "lower is better" metrics. Use it as a gradient or data bar source so that green always means good.

## Common problems

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Color measure not in the Field value list | Measure returns a number, not text | Return a hex string such as `"#2E7D32"` |
| Every row gray | Status returns "No data" or blank at that grain | Check the status measure at the row level |
| Totals row shows a single color | Status is evaluated for the whole selection | Return blank at total level with `ISINSCOPE`, or accept the rule for totals |
| Icon missing on some rows | Code measure returns blank | Make sure every status maps to a code |
