require("ggplot2")
require("ggthemes")
library("dplyr")
library("reshape2")
library("scales")

source("commonlibs_r/theme_comhis.R")
source("commonlibs_r/output.R")

# load plot data from csv (generated with fig10_data.py)
plot_data <- read.csv("../output/data/fig10_booktrade_percentile_share.csv", stringsAsFactors = F)
plot_data$sum <- with(plot_data, X1 +  X5 + X10 + X20 + X40 + X100)

# by decade, just 1st
plot_data$decade <- floor(plot_data$year / 10) * 10
decdata <- aggregate(plot_data['X1'], by=plot_data['decade'], sum)
decdata$sum <- aggregate(plot_data['sum'], by=plot_data['decade'], sum)$sum
decdata$share <- decdata$X1 / decdata$sum

# # prev version
# # make plot data "tidy" for ggplot and wiggle stuff around types for some obscure reason
# molten_plot_data <- melt(plot_data, id.vars = "year", variable.name = "percentile")
# molten_plot_data$percentile <- as.character(molten_plot_data$percentile)
# molten_plot_data$percentile <- substr(molten_plot_data$percentile, 2, nchar(molten_plot_data$percentile))
# molten_plot_data$percentile <- factor(molten_plot_data$percentile, levels = sort(as.numeric(as.character(unique(molten_plot_data$percentile)))))
# molten_plot_data$Percentile <- molten_plot_data$percentile
# # just 1st percentile
# # molten_plot_data <- molten_plot_data[which(as.character(molten_plot_data$Percentile) == "1"),]
# 
# # create plot
# plot <- ggplot(molten_plot_data, aes(x=year, y=value, fill=Percentile)) +
#   geom_area(position="fill") + 
#   theme_comhis(type="discrete") +
#   labs(y="Titles (%)", x="Year") +
#   scale_y_continuous(labels = percent)

plot <- ggplot(decdata, aes(x=decade, y=share)) +
  geom_col() + 
  theme_comhis(type="discrete") +
  labs(y="Share (%)", x="Decade") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 10L))


# check plot in R Studio
plot

# save plot
save_plot_image(plot, plotname = "fig10_share_by_publisher_percentile", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "png", width=19, height=10)
save_plot_image(plot, plotname = "fig10_share_by_publisher_percentile", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=10)
