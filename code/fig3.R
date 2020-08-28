source("init.R")

# Generate data sets with
# source("data.R")

# Load the necessary data frames
ac41 <- readRDS("ac41.Rds") # Generated in "data.R"
gg3 <- readRDS("gg3.Rds") # Generated in "data.R"
dd <- readRDS("dd.Rds") # Generated in "data.R"
canon <- read.csv(canon_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

# Pick the necessary data frame for Figure 19
source("fig3_data.R")

# Plot figures
source("fig3_figure.R")

