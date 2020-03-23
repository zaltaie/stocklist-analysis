#Hedge fund portfolio analysis
rm(list=ls())

library(quantmod)
library(PerformanceAnalytics)
library(magrittr)

data("HedgeFund")
scenario_set <- HedgeFund

assets <- ncol(scenario_set)
scenarios <- nrow(scenario_set)

cat("\n", paste0(names(scenario_set), "\n"))

chart.Bar(scenario_set$EventDriven)
charts.PerformanceSummary(scenario_set$EventDriven)

#Easy Markotiz portfolio optimization
library(tseries)



