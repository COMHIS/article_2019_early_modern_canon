source("init.R")

# Load the necessary data frames

ac4 <- readRDS("ac4.Rds") # Generated in "data.R"
canon.works <- readRDS("canon.works.Rds") # Generated in "data.R"
canon <- read.csv(canon_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))


# Pick the necessary data frame 
source("fig4_data.R")

# Plot figure 
source("fig4_figure.R")

