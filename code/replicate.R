################################
## Author: Mark Huberty
## Date: 8 May 2012
## Runs the replication sequence
################################

setwd("~/Documents/grn_exports_engpol")
figure.format <- "pdf"
figure.dir <- "./figures"

## Source files in sequence. These files reference the config variables defined above

print("calculating RCA values")
source("./code/calculate_rca.R")

print("calculating proximity values")
source("./code/calculate_prox.R")

print("calculating summary proximity matrices")
source("./code/summarize_prox.R")

print("generating product space graphs")
source("./code/plot_product_space.py")

print("building model matrix")
source("./construct_model_matrix.R")

print("running analyses and outputting tables")
source("analyze_model_matrix.R")

print("Done")
quit()
