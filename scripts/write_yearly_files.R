## Code to write out the yearly files for the un data
## Necessary to handle the size of the files - can't load the entire
## file at once

setwd("~/Documents/trade_data")
load("comtrade_all_intermediate_df.RData")



un.data <- mat.temp
rm(mat.temp)
#un.data <- drop.levels(un.data)
gc()


## Fix the variable classes
un.data$TradeQuantity <- as.numeric(as.character(un.data$TradeQuantity))
un.data$NetWeight <- as.numeric(as.character(un.data$NetWeight))
un.data$TradeValue <- as.numeric(as.character(un.data$TradeValue))
un.data$yr <- as.numeric(as.character(un.data$yr))

years <- unique(un.data$yr)

for(i in 1:length(years))
  {

    out.data <- un.data[un.data$yr==years[i],]

    save(out.data, file=paste("undata.", years[i], ".RData", sep=""))

    un.data <- un.data[-(un.data$yr==years[i]),]
    gc()


  }

## end
