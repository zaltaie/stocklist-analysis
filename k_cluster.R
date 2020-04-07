setwd("~/Desktop/R project/Stock Finance")


library(quantmod)
library(PerformanceAnalytics)
library(magrittr)
library(tseries)

start_time <- Sys.time()

tradingData <- read.csv("NYSE.csv", header = TRUE) #unable to upload due to file is >25mb

str(tradingData)

head(tradingData, n=5)

colnames(tradingData) <- c("ID","OPEN_P", "HIGH_P", "LOW_P", "CLOSE_P", "VOLUME", "CLOSE_ADJ_P")

#drop ID column
tradingData <- tradingData[, -c(1)]

#standardize the continuous numbers
tradingData <- scale(tradingData)

#perform kmeans with k = 4
fit <- kmeans(tradingData, centers = 4, iter.max = 10000)

#display the results, taken from the fit table centers
fit$centers
View(fit$centers)

end_time <- Sys.time()
total_time <- end_time - start_time
total_time
