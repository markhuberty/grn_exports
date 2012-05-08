## Code to get the bulk downloads for Eurostat trade data
## Project on RCA and climate policy over time
## Begun 21 October 2010

## NOTE: Access to the COMTRADE database is restricted. This code was
## run from an IP address inside the Berkeley IP domain, allowing
## access via Berkeley's subscription to the COMTRADE database. 


if(grepl("mac.binary", .Platform$pkgType, fixed=TRUE))
  {

    setwd("~/Documents/Research/Dissertation/Data/eurostat_trade")

  }else{

    setwd("~/Documents/trade_data")

  }
library(RCurl)

## Base URL from Eurostat
## base.url <- "http://epp.eurostat.ec.europa.eu/NavTree_prod/everybody/BulkDownloadListing?sort=1&file=comext%2F2010S2%2Fdata%2F"#199552.7z

## years <- 1988:2009

## targets <- paste("nc",years, "52.7z", sep="")

## urls.complete <- paste(base.url, targets, sep="")

## n <- length(urls.complete)
## #n <- 2

## ## Get all the urls and write out the binary files
## for(i in 1:n)
##   {
##     f <- getBinaryURL(urls.complete[i])
##     writeBin(f, targets[i])
##   }

## ## Unzip the gotten files
## ## Note that you need the extra quotes around the wildcards to get
## ## do the multi-file extract.
## system("7za x \"*.7z\"")



## Analgous code for UN COMTRADE. Note that this must be run from
## within CAL to use the webservices layer of COMTRADE.

library(XML)
library(RCurl)

## Get the country code list from the UN master file and parse it
## for use in the following code
countries <-
  xmlTreeParse("http://comtrade.un.org/ws/refs/getCountryList.aspx", isURL=TRUE)

countries.root <- xmlRoot(countries)

n <- length(countries.root)
#n <- 2

for(i in 1:n)
  {

    code <- xmlValue(countries.root[[i]][[1]])
    name <- xmlValue(countries.root[[i]][[2]])

    out <- c(code, name)

    if(i==1)
      mat.out <- out
    else
      mat.out <- rbind(mat.out, out)
    
  }

mat.out <- as.data.frame(mat.out)
rownames(mat.out) <- paste("r", 1:dim(mat.out)[1], sep="")
names(mat.out) <- c("code", "name")
mat.out$code <- as.integer(as.character(mat.out$code))
mat.out$name <- as.character(mat.out$name)

save(mat.out, file="country.codes.RData")


## Set up the URL format for the COMTRADE database
base.url <- "http://comtrade.un.org/ws/get.aspx?"

Rg <- 2 ## Exports
Px <- "HS" ## All codes
Y <- "All" ## All years
CC <-  "*" ## 
P <- 0 ## To World
comp="FALSE" ## Don't compress

out.list <- list()

m <- dim(mat.out)[1]
#m <- 2

## library(snow)
## setDefaultClusterOptions(master="localhost")

library(RCurl)
for(x in 1:m)
  {
    ## For all countries

    ## Construct the specific URL for that country
    url <- paste(base.url,
                 "rg=", Rg,
                 "&px=", Px,
                 "&y=", Y,
                 "&cc=", CC,
                 "&r=", mat.out[x,1], ## the country code
                 "&p=", P,
                 "&comp=", comp,
                 sep=""               
                 )
    print(url)
    print(mat.out[x,2])

    ## Get the data (try statement to trap html errors)
    out.df <- try(xmlToDataFrame(url, colClasses=rep("character", 13)
                                 )
                  )

    ## Handle corruption of the data mid-stream
    while(class(out.df)=="try-error")
      {
        System.sleep(5)
        
        out.df <- try(xmlToDataFrame(url, colClasses=rep("character", 13)
                                     )
                      )

      }

    ## Handle data so that it doesn't segfault R
    ## For x = 1 and each 25 X, reset the list
    ## if X is on the interval 25, 50, 75, etc, delete the old record
    ## and start over
    if(x==1 | x %% 25 == 0)
      {
        if(x %% 25 == 0)
          {
            save(list.out, file=paste("un_comtrade_", x, ".RData", sep=""))
            rm(list.out)
            gc()
          }
        
        list.out <- out.df
        #names(list.out)[x] <- mat.out[x,2]

      }else{
        list.out <- c(list.out, out.df)
        #names(list.out)[x] <- mat.out[x,2]
      }
    
  } ## end of for loop for acquisition
                        

save.image("trade.out.final.RData")
