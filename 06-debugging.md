# 06. Debugging

How to find the cause when a measure returns blank, the wrong number, or an error.

## A repeatable approach

1. **Reduce the visual.** Put the measure in a card or a single-row table with no slicers, then add filters back one at a time.
2. **Return intermediate values.** Temporarily change the `RETURN` line to a variable to see its value.

```dax
Debug Example =
VAR Result = [SLA Result]
VAR Goal = [SLA Goal]
RETURN
    Result -- swap in Goal, then the final expression, to see where it goes wrong
```

3. **Check data types and relationships first.** Most wrong numbers trace back to the model, not the DAX.
4. **Use the tools.** Performance Analyzer (View tab) shows which visual and query is slow. DAX Studio and the DAX query view let you run measures against the model directly.

## Circular dependency

**Error:** "A circular dependency was detected."

It happens when two calculations depend on each other, directly or through a relationship. The most common case is a calculated column that uses a measure or another table's column, while that other table's relationship or column depends back on the first.

Ways out:

| Fix | When to use it |
| --- | --- |
| Turn the calculated column into a measure | The value depends on filter context, not on the row |
| Move the calculation into Power Query | The value is row-level and fixed |
| Break the loop with a staging column | Two columns each need part of the other's result |

If the dependency passes through a relationship, check whether the column is used as a key.

## Null and logical errors

Wrong results often come from types set upstream. If a column that should be numeric or date is text or "any," comparisons and sums behave oddly or return errors.

- Check the column type icons in Power Query, not just in the report.
- Apply types in one explicit step (see `fnApplyTypes` in the Power Query Function Library).
- Make sure each fix step feeds the next one, so a later step does not quietly read the original column.

## Date filtering problems

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Measure ignores the date slicer | Slicer built on the fact table's date, measure filters `DimDate` | Build the slicer from `DimDate` |
| Time intelligence returns blank | Date table has gaps or is not marked | Make the calendar contiguous and mark it as a date table |
| Totals differ between visuals | Different date columns used (fact vs. date table) | Standardize on `DimDate` columns |
| Month totals miss rows | Fact dates have a time portion | Convert to date type in Power Query |

## Calendar and grain mismatches

A relationship needs both sides to be at the same grain. If the fact table holds month start dates, the date table must contain those exact dates and the column must be the key. Use first-of-month dates on the fact side, or relate on a month column instead of the daily date.

## Quick checks before you publish

- [ ] Every measure tested with no filters, one filter, and many filters
- [ ] Totals match a hand calculation for at least one program and one month
- [ ] Blank and zero cases behave as intended
- [ ] No relationship warnings in Model view
- [ ] Date table marked, contiguous, and used for every date visual
