## Takes by-year UN COMTRADE data
## and computes the RCA matrix for all goods and countries for
## that year.

library(gdata)
library(foreach)
library(doMC)
library(reshape)
setwd("~/Documents/trade_data/undata_yr")
source("../code/trade_functions.R")

## Set the HS detail level at which to calculate the
## RCA values
detail.level <- c(2,4,6)
detail.directories <- c("unrca2", "unrca4", "unrca6")

## Get the list of files. Assumes files are
## named in the for undata.<detail>.RData
data.list <-
  system("ls | grep undata | grep RData | grep -v rca.detail",
         intern=TRUE)

years <- 1988:2010

## Want to only look at the top 80% of trade; the last 20% are miniscule.
trader.cutoff <- 0.2

for(j in 1:length(detail.level)){
  
  for(i in 1:length(data.list))
    {
      load(data.list[i])

      print(dim(out.data))

      ## Calculate total exports by country
      tot.exports <- tapply(out.data$TradeValue,
                            out.data$rtCode,
                            sum,
                            na.rm=TRUE
                            )
      
      ## Compute the nth quantile
      quantile.exp <- quantile(tot.exports, probs=trader.cutoff, na.rm=TRUE)

      ## Determine what countries qualify
      countries.keep <- levels(out.data$rtCode)[tot.exports >= quantile.exp]

      ## Take only the countries in the cutoff list
      out.data <- out.data[out.data$rtCode %in% countries.keep,]

      print(dim(out.data))

      
      rca <- calc.rca(out.data,
                      prod.level=detail.level[j],
                      pl=0
                      )

      save(rca,
           file=paste("../",
             detail.directories[j],
             "/rca.detail.vec",
             detail.level[j],".",
             data.list[i],
             sep=""
             )
           )

      ## Clean up and dump memory
      rm(out.data, rca)
      gc()

    }

}
