library(foreach)
library(doMC)
library(multicore)

setwd("~/Documents/trade_data/")
source("./code/trade_functions.R")

## Get the directories to loop through
dirs <- system("ls | grep un | grep rca | grep -v prox", intern=TRUE)
dirs <- paste("~/Documents/trade_data/", dirs, sep="")

#registerDoMC(3)

for(d in 1:length(dirs))
  {
    setwd(dirs[d])

    ## Get the relevant files in each directory.
    ## Assumes files named as noted in the rca_calculation code
    files <- system("ls | grep rca.detail | grep -v prox", intern=TRUE)

    ## Memory usage runs close to max with the 6-digit data
    ## Reduce cores to reduce memory footprint
    ## if(d==3)
    ##   options(cores=2)
    
    for(f in 1:length(files))
      {
        
        load(files[f])
        print(files[f])
        
        prox.out <- try(calc.proximity.matrix(rca))

        if(!grepl("try",prox.out, fixed=TRUE))
          save(prox.out, file=paste("prox.", files[f], sep=""))

        rm(rca)
      }

    rm(files)
  }





