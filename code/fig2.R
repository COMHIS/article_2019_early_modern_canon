
source("init.R")

# Generate data sets with
# source("data.R")

# Load the necessary data frames
ac41 <- readRDS("ac41.Rds") # Generated in "data.R"
canon <- read.csv(canon_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

# Pick the necessary data frame for Figure 19
source("fig2_data.R")

# Plot figures
source("fig2_figure.R")

# ---------------

# 
#subject-topic: simplified_dd_subject
#number of editions,
#included/excluded from most analysis

canon_table <- canon %>% filter(is_canon == TRUE) %>%
                         select(author,
			        title, work_titles,
			        simplified_dd_subject)# %>%


#yo <- ac41 %>% filter(finalWorkField %in% xc2$work_titles) %>%



