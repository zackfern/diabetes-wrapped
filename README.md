# Diabetes Wrapped
Diabetes Wrapped is a web application that connects to Nightscout and calculates
aggregate yearly stats based off CGM readings and insulin deliveries.

It is meant for entertainment purposes only as a way to give diabetics a fun glimpse
into their care routine. The calculations are best-efforts based off available data
(see methodologies below) and should not be used for any form of treatment decision.

# How stats are calculated
## Insulin Stats
### Total Bolus Units and Bolus Count
For each treatment API record that has a type containing the word "Bolus", we will add its
`insulin` field to a running total of boluses for the month.

For each of these records we will also iterate the Bolus Count.

### Total Basal Units
Basal usage is tricky to calculate using the Nightscout API. The implementation in this app
is informed by, but NOT a direct re-implementation of, how Nightscout calculates basal in its reports.

In short:
1. We query for 25 profiles when starting a report and then cache them on the server.
1. When iterating over a day, we will attempt to find the appropriate profile that would have
   been used at the time. We select the default profile from this version.
1. When looking at treatment data for a day, we create a list of all temp basal events.
1. We then iterate over the list of temp basals to fill in the blanks with the default profile
   basal rate at the time.
1. Finally, we iterate over the list of combined scheduled basals and temp basals and add up
   the sum of the units.

Because of the variability in data, it's very possible that this can result in inaccurate
estimates. Again, this is a fun app, so don't rely on this number!

### Total Insulin
Total Bolus Units + Total Basal Units

## CGM Stats
### Wake Ups
We consider you to have been woken up in the middle of the night if a
CGM reading is below the target range between the hours of midnight and 6 AM.

### Days in Range
A day is considered in range if all CGM readings fall within the user's defined `range_min` and `range_max`.

# Architecture Overview
The site is a Ruby on Rails web application which relies on background workers to query
Nightscout and formulate reports. The report is based off of the database records described
above and based off the HTML ERB template at `app/views/reports/show.html.erb`.

## Models (database records)
- A **User** represents a user of the service. Beyond the user's email address, it
  contains configuration information like the Nightscout host, token, user timezone,
  CGM units (mg/dL or mmol/L), and minimum/maximum range.
- A **Report** represents a "year wrapped" - it contains the year we're querying for,
  if we should include insulin (based off of if a treatment is found on initial query)
  or skip requets for treatments if none exist, as well as aggregate stats for all months
  of the year (total insulin, days in range, wake ups).
- A **ReportMonth** belongs to a Report and contains stats for one month of the year. It
  contains many of the same fields above (total insulin, days in range, wake ups).

## Background Jobs
### MonthlyReportJob
The **MonthlyReportJob** is the core of the application, responsible for calculating a
month's worth of aggregate statistics at a time. It queries the user's Nightscout instance
for `entries` and `treatments` for every day of the month. While ineffecient, this is
unfortunately the best way to ensure that we see all CGM readings and insulin pump treatments.

This job is responsible for creating `ReportMonth` records, querying Nightscout for blood
glucose, querying Nightscout for insulin treatments (only if the report has include_insulin
set to true), and enqueueing the next relevant job – either another `MonthlyReportJob` to find
the next month's worth of stats, or the `ReportOrchestrationJob` to finish the report.

### ReportOrchestrationJob
The **ReportOrchestrationJob** runs at the beginning and end of the report generation process.

It will either enqueue the first `MonthlyReportJob`, if the Report has the status not_started,
or it will add up total stats across the year from each child `ReportMonth` and set a report
to status finished.

# Running It
The application is a straightforward Ruby on Rails web application, which can be run either
locally in development mode or deployed elsewhere. It is also available to use at
https://diabeteswrapped.com for a limited time (around the end/beginning of the year).

This README won't cover how to install and run Ruby and/or Rails, please refer to the offical
[Rails Installation Guide][1] for a walkthrough if you're unfamiliar.

[1]: https://guides.rubyonrails.org/install_ruby_on_rails.html
