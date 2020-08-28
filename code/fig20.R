source("init.R")

# Load the necessary data frames
ac41 <- readRDS("ac41.Rds") # Generated in "data.R"

canon.works <- readRDS("canon.works.Rds") # Generated in "data.R"
canon <- read.csv(canon_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))


# Pick the necessary data frame 
source("fig20_data.R")

# Plot figure 
source("fig20_figure.R")

