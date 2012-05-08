## Code to load and reformat the Eurostat files
## 28 October 2010
## Mark Huberty
library(foreach)
library(multicore)
library(doMC)

#registerDoMC(3)

setwd("~/Documents/trade_data/eu_data_yr")

files <- system("ls | grep .dat", intern=TRUE)

summarize.eu.data <- function(input){
  
  ## short.data <- input[input$flow==2,c(1,3,5)]
  ## short.data <- unique(short.data)
  ## short.data$exp.value <- NA

  input <- input[input$flow==2,]
  countries <- unique(input$declarant)
  #codes <- unique(input$product_nc)
  
  summary.data <-  foreach(i=1:length(countries),.combine=rbind) %dopar% {

    ctry <- countries[i]
    ctry.codes <- input$product_nc[input$declarant==ctry]
    st.regime <- input$stat_regime[input$declarant==ctry]
    
    out <- tapply(input$value_1000ecu[input$declarant==ctry],
                  ctry.codes,
                  sum,
                  na.rm=TRUE
                  )

    out <- cbind(as.character(ctry),
                 as.character(levels(ctry.codes)),
                 #as.character(unique(st.regime)),
                 as.character(out)
                 )
    
                         
    }

  return(summary.data)
  
}

for(i in 1:length(files))
  {

    raw.data <- read.csv(files[i], header=TRUE)
    names(raw.data) <- tolower(names(raw.data))

    out.data <- summarize.eu.data(raw.data)

    rm(raw.data)
    gc()

    names(out.data) <- c("rtCode", "cmdCode", "statRegime", "TradeQuantity")
    save(out.data, file=paste("reduced",
                     gsub(".dat", "", files[i], fixed=TRUE),
                     ".RData",
                     sep="")
         )

    rm(out.data)
    gc()
  



  }
