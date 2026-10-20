# 04. Nulls and Safe Math

Blank handling is a common source of surprises. These patterns keep results predictable.

## Safe division

```dax
Safe Ratio = DIVIDE ( [Numerator], [Denominator] )

Safe Ratio (zero if empty) = DIVIDE ( [Numerator], [Denominator], 0 )
```

`DIVIDE` returns blank on divide-by-zero by default. The optional third argument sets a different result. Prefer it over `IF ( [Denominator] = 0, ... )`, which is slower and easy to get wrong.

## How blanks behave

| Expression | Result |
| --- | --- |
| `BLANK () + 5` | 5 |
| `BLANK () * 5` | blank |
| `BLANK () = 0` | TRUE |
| `ISBLANK ( 0 )` | FALSE |

Because `BLANK () = 0` is true, use `ISBLANK` when you need to tell "no data" apart from "zero".

## Replace blank with a default

```dax
Amount or Zero = COALESCE ( [Total Amount], 0 )
```

Careful: this returns 0 for every date, including future months with no data, so a trend line will drop to zero after your last data point.

## Zero-fill only up to the last data date

```dax
Amount (zero-filled) =
VAR HasData = NOT ISBLANK ( [Total Amount] )
VAR WithinData = MAX ( DimDate[Date] ) <= [Latest Data Date]
RETURN
    IF ( HasData, [Total Amount], IF ( WithinData, 0 ) )
```

Months inside the reporting period with no activity show zero. Future months stay blank and drop off the chart.

## Single-value checks

```dax
Selected Program =
IF (
    HASONEVALUE ( FactInvoices[Program] ),
    VALUES ( FactInvoices[Program] ),
    "Multiple"
)

Selected Program (shorter) =
SELECTEDVALUE ( FactInvoices[Program], "Multiple" )
```

## Common problems

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| "Cannot convert value of type Text to Number" | Text column used in math | Fix the type upstream in Power Query, not in the measure |
| Rows show 0 instead of blank | `COALESCE` or `+ 0` applied everywhere | Use the zero-fill pattern above |
| Blank rows disappear from a table | Visual hides rows where all measures are blank | Add a measure that returns 0 or a label, or use the zero-fill pattern |
| `IF ( [Measure] = 0, ... )` fires on blanks | Blank equals zero in comparisons | Test with `ISBLANK` first |
