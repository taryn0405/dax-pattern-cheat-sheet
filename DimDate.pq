// DimDate
// Daily date table with an October fiscal year start.
// The fiscal year is named for the calendar year in which it ends
// (Oct 2025 through Sep 2026 is FY2026).
//
// After loading: mark this table as a date table (Table tools > Mark as date table),
// then sort "Month Label" by "Month Sort".

let
    StartDate = #date(2024, 10, 1),
    EndDate = #date(2026, 12, 31),
    FiscalStartMonth = 10,

    Dates = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),
    Source = Table.FromList(Dates, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    Typed = Table.TransformColumnTypes(Source, {{"Date", type date}}),

    AddMonthStart = Table.AddColumn(Typed, "Month Start", each Date.StartOfMonth([Date]), type date),
    AddYear = Table.AddColumn(AddMonthStart, "Calendar Year", each Date.Year([Date]), Int64.Type),
    AddMonthNum = Table.AddColumn(AddYear, "Month Number", each Date.Month([Date]), Int64.Type),
    AddMonthLabel = Table.AddColumn(AddMonthNum, "Month Label", each Date.ToText([Date], "MMM yyyy"), type text),
    AddMonthSort = Table.AddColumn(AddMonthLabel, "Month Sort", each [Calendar Year] * 100 + [Month Number], Int64.Type),

    AddFiscalYear = Table.AddColumn(
        AddMonthSort,
        "Fiscal Year",
        each if FiscalStartMonth = 1 then [Calendar Year]
             else if [Month Number] >= FiscalStartMonth then [Calendar Year] + 1
             else [Calendar Year],
        Int64.Type
    ),
    AddFiscalMonth = Table.AddColumn(
        AddFiscalYear,
        "Fiscal Month",
        each Number.Mod([Month Number] - FiscalStartMonth + 12, 12) + 1,
        Int64.Type
    ),
    AddFiscalQuarter = Table.AddColumn(AddFiscalMonth, "Fiscal Quarter", each Number.RoundUp([Fiscal Month] / 3), Int64.Type),
    AddFiscalQuarterIndex = Table.AddColumn(
        AddFiscalQuarter,
        "Fiscal Quarter Index",
        each [Fiscal Year] * 4 + [Fiscal Quarter],
        Int64.Type
    ),
    Result = Table.AddColumn(
        AddFiscalQuarterIndex,
        "Fiscal Period Label",
        each "FY" & Text.From([Fiscal Year]) & " Q" & Text.From([Fiscal Quarter]),
        type text
    )
in
    Result
