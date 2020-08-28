source("init.R")

# Generate data sets with
# source("data.R")

# Load the necessary data frames
# ac41 <- readRDS("ac41.Rds") # Generated in "data.R"
# canon <- read.csv(canon_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))
gg3 <- readRDS("gg3.Rds") # Generated in "data.R"

# Pick the necessary data frame for Figure 19
source("fig15_data.R")

# Plot figures
source("fig15_figure.R")





