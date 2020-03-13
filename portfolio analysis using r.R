rm(list=ls())

library(quantmod)
library(xgboost)
library(pROC)

getSymbols("AMD")
chartSeries(AMD, 
			subset = 'last 6 months',
			up.col = 'green',
			dn.col = 'red')
addBBands(n = 20, 
		  sd = 2, 
		  maType = "SMA", 
		  draw = "bands", 
		  on = -1)

tickers <- c("AAPL", "ADBE", "AMZN", "SNAP", "AMD", 
					   "TWTR", "GOOGL", "CRM", "EBAY", "FB", "INTL", 
					   "MSFT", "MU", "NFLX", "SBUX", "TSLA", "VOD", 
					   "DIS", "BA", "NVDA", "LULU", "SQ", "PLUG")
getSymbols(tickers)

# merge them all together
portf <- data.frame(as.xts(merge(AAPL, ADBE, AMZN, SNAP, AMD, 
									 TWTR, GOOGL, CRM, EBAY, FB, INTL, 
									 MSFT, MU, NFLX, SBUX, TSLA, VOD, 
									 DIS, BA, NVDA, LULU, SQ, PLUG)))
head(portf[,1:12],2)

outcome_symbol <- 'FISV.Volume'