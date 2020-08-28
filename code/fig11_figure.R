require("ggplot2")
require("ggthemes")
library("dplyr")
library("reshape2")
library("scales")

source("commonlibs_r/theme_comhis.R")
source("commonlibs_r/output.R")

# load plot data from csv (generated with fig10_data.py)
plot_data <- read.csv("../output/data/fig11_canon_share_by_publisher_percentile.csv", stringsAsFactors = F)
plot_data <- plot_data[, c("percentile", "canon_share_of_whole_canon", "non_canon_share_of_whole_non_canon")]
# plot_data$sum <- with(plot_data, X1 +  X5 + X10 + X20 + X100)
# plot_data$share1 <- plot_data$X1 / plot_data$sum
colnames(plot_data) <- c("percentile", "Canon", "Other")
plot_data$percentile <- as.character(plot_data$percentile)
plot_data <- plot_data[which(plot_data$percentile == "1"), ]

# make plot data "tidy" for ggplot and wiggle stuff around types for some obscure reason
molten_plot_data <- melt(plot_data, id.vars = "percentile", variable.name = "Category")
molten_plot_data$percentile <- factor(molten_plot_data$percentile, levels = sort(as.numeric(as.character(unique(molten_plot_data$percentile)))))
molten_plot_data$percentile <- as.numeric(molten_plot_data$percentile)

# create plot
plot <- ggplot(molten_plot_data) +
  geom_col(aes(x = Category, y = value), fill = c("darkgreen", "darkgray"), color = "black") + 
  theme_comhis(type="discrete", base_size = 15) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 10L)) +
  labs(y = "Share (%)", x = "")

plot

# save plot
save_plot_image(plot, plotname = "fig11_canon_share_by_publisher_percentile", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "png", width=12, height=12)
save_plot_image(plot, plotname = "fig11_canon_share_by_publisher_percentile", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=12, height=12)
