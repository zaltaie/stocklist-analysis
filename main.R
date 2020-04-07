rm(list=ls())

library(reshape2)
library(dplyr)
library(ggplot2)
library(quantmod)
library(PerformanceAnalytics)

getSymbols("AMD")
chartSeries(AMD, subset = 'last 6 months', up.col = 'green', dn.col = 'red')
addBBands(n = 20, sd = 2, maType = "SMA", draw = "bands", on = -1)
addMACD()

max_date <- "2000-01-01"

#Calculating the Value-at-Risk(VaR) and conditional value at risk (CVAR) of AMD across 95 and 99 percentiles.
AMD_returns <- dailyReturn(AMD)
VaR(AMD_returns, p = 0.95, method = "historical")
VaR(AMD_returns, p = 0.99, method = "historical")

CVaR(AMD_returns, p = 0.95, method = "historical")
CVaR(AMD_returns, p = 0.99, method = "historical")

#Setting up portfolio stocks to do analysis 
tickers <- c("MSFT", "SQ", "AMD", "AAPL", "GOOGL")
weights <- c(0.1, 0.3, 0.1, 0.3, 0.2)
getSymbols(tickers, from= max_date)

port_prices <- merge(Ad(MSFT), Ad(SQ), Ad(AMD), Ad(AAPL), Ad(GOOGL)) %>% na.omit()

port_returns <- ROC(port_prices, type = "discrete")[-1] #Calculating the returns ROC(Return of change) of portfolio 

colnames(port_returns) <- tickers

#Calculating the Value-at-Risk(VaR) and conditional value at risk (CVAR) of stocks across 99 percentiles.
VaR(port_returns, p = 0.99, weights = weights, portfolio_method = "component", method = "modified") #We can see that the highest risk of loss in the 1% of scenarios is going to be SQ and AMD. 
#That is to be expected as Square is a fairly new company and are still in their growth phase. 
#This could be due to the high weight in the stock. 
CVaR(port_returns, p = 0.99, weights = weights, portfolio_method = "component", method = "modified")

#Lets plot this!
VaR_hist <- VaR(port_returns, p = 0.95, weights = NULL, portfolio_method = "single", method = "historical")
VaR_gas <- VaR(port_returns, p = 0.95, weights = NULL, portfolio_method = "single", method = "gaussian")
VaR_mod <- VaR(port_returns, p = 0.95, weights = NULL, portfolio_method = "single", method = "modified")
All_VaR <- data.frame((rbind(VaR_mod, VaR_gas, VaR_hist)))
rownames(All_VaR) <- c("Hist", "Gas", "Mod")

Port_VaR_hist <- VaR(port_returns, p = 0.95, weights = weights, portfolio_method = "component", method = "historical")$hVaR[1]
Port_VaR_gas <- VaR(port_returns, p = 0.95, weights = weights, portfolio_method = "component", method = "gaussian")$VaR[1]
Port_VaR_mod <- VaR(port_returns, p = 0.95, weights = weights, portfolio_method = "component", method = "modified")$MVaR[1]

All_VaR$Portfolio <- 0
All_VaR$Portfolio <- c(Port_VaR_hist, Port_VaR_gas, Port_VaR_mod)
head(All_VaR)
All_VaR <- abs(All_VaR)
All_VaR$Type <- c("Hist", "Gaus", "Mod")

plot_Var <- melt(All_VaR, variable.name = "Ticker", value.name = "VaR")
ggplot(plot_Var, aes(x= Type, y= VaR, fill=Ticker)) +
	geom_bar(stat = "identity", position = "dodge")

charts.PerformanceSummary(port_returns, main = "Portfolio returns", colorset= rich6equal)

#Create a risk report exported to excel
i = 1
for (t in tickers){
	mean = c(mean, mean(port_returns[,i]))
	sd = c(sd, sd(port_returns[,i]))
	var005 = c(VaR_hist, quantile(port_returns[,i], 0.05))
	cvar = mean(sort(port_returns[,1][1:(round(length(port_returns[,i])*0.5))]))
	i = i +1
}

risk_report <- data.frame(tickers, mean, sd, var005, cvar)
names(risk_report) <- c("Symbols", "Mean (1yr)", "St.dev", "VaR (0.05)", "CVaR")
write.csv2(risk_report, file = "risk_report.csv")
