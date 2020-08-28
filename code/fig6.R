source("init.R")

# Load the necessary data frames
ac4 <- readRDS("ac4.Rds") # Generated in "data.R"

# Pick the necessary data frame 
source("fig6_data.R")

# Plot figure 
source("fig6_figure.R")

library(rmarkdown)
render("fig6.Rmd", output_format = "md_document")