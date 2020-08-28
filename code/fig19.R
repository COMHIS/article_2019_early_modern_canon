source("init.R")

# Load the necessary data frames
ac41 <- readRDS("ac41.Rds") # Generated in "data.R"
canon <- read.csv(canon_csv)

# Pick the necessary data frame for Figure 19
source("fig19_data.R")

# Plot figure 19
source("fig19_figure.R")

