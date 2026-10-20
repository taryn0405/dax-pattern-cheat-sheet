// FactSLA
// Mock monthly SLA results: 3 programs x 3 metrics x 24 months = 216 rows.
// Each row has its own goal and a flag for whether higher or lower is better,
// which is the "mixed" SLA setup used in patterns/05-sla-attainment.md.
// Month is always the first day of the month so it relates cleanly to DimDate[Date].
// All data is fabricated.

let
    Programs = {"Program A", "Program B", "Program C"},
    Metrics = {"On-Time Fill %", "Invoice Accuracy %", "Time to Fill (days)"},
    Goals = {0.90, 0.98, 30},

    Rows = List.Transform(
        {0..215},
        each
            let
                m = Number.Mod(Number.IntegerDivide(_, 3), 3),
                isDays = (m = 2)
            in
                [
                    Program = Programs{Number.Mod(_, 3)},
                    Month = Date.AddMonths(#date(2024, 10, 1), Number.IntegerDivide(_, 9)),
                    Metric = Metrics{m},
                    Goal = Goals{m},
                    HigherIsBetter = not isDays,
                    Result =
                        if isDays
                        then 24 + Number.Mod(_ * 5, 14)
                        else Number.Round(0.85 + Number.Mod(_ * 7, 15) / 100, 2)
                ]
    ),

    Result = Table.FromRecords(
        Rows,
        type table [Program = text, Month = date, Metric = text, Goal = number, HigherIsBetter = logical, Result = number]
    )
in
    Result
