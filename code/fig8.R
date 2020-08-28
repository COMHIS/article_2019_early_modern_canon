source("init.R")

# Generate data sets with
# source("data.R")

# Load the necessary data frames
#ac4 <- readRDS("ac4.Rds") # Generated in "data.R"
ac41 <- readRDS("ac41.Rds") # Generated in "data.R"
#canon <- read.csv(canon_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

# Pick the necessary data frame for Figure 19
source("fig8_data.R")

# Plot figures
source("fig8_figure.R")

