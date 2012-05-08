## Code to reformat the comtrade data based on get_ code
## Project on RCA and climate policy over time
## Begun 24 October 2010

if(grepl("mac.binary", .Platform$pkgType, fixed=TRUE))
  {

    setwd("~/Documents/Research/Dissertation/Data/eurostat_trade")

  }else{

    setwd("~/Documents/trade_data")

  }

data.vector <- system("ls | grep un_comtrade", intern=TRUE)

data.vector <- c(data.vector,
                 "trade.out.final.RData"
                 )

## Loop across all the data and reformat into a single data frame
for(i in 1:length(data.vector))
  {

    ## Load the data
    load(data.vector[i])

    ## Count how many countries are in there. Countries that didn't
    ## return anything don't appear in the list
    
    country.count <- length(list.out)/13 ## 13 elements in the data frame

    ## Loop across all countries in this data set
    for(j in 1:country.count)
      {
        ## If it's the first data set and the first country
        ## Create the object to store all data
        if(i==1 & j==1)
          {
            
            mat.temp <- sapply(1:13, function(x){
              
              list.out[[x]]
              
            }
                               )
            
            ## Otherwise append to that dataset
          }else{
            
            from.idx <- (j-1)*13+1
            to.idx <- from.idx+12
            mat.temp2 <- sapply(from.idx:to.idx, function(x){

              list.out[[x]]
              
            }
                                )

            mat.temp <- rbind(mat.temp, mat.temp2)

            rm(mat.temp2)
            gc()
          }

        print(dim(mat.temp))
      }
  }

#class(mat.temp) <- "data.frame"
#gc()

names.mat.temp <- names(list.out)[1:13]

colnames(mat.temp) <- names(list.out)[1:13]
rownames(mat.temp) <- paste("r", 1:dim(mat.temp)[1], sep="")

save(names.mat.temp,mat.temp, file="comtrade_all_intermediate.RData")

class(mat.temp) <- "data.frame"

save(mat.temp, file="comtrade_all_intermediate_df.RData")

## end
