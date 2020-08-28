require("ggplot2")
require("ggthemes")
library("dplyr")
library("reshape2")
library("scales")

source("commonlibs_r/theme_comhis.R")
source("commonlibs_r/output.R")

# load plot data from csv (generated with fig10_data.py)
plot_data <- read.csv("../output/data/fig12_all_publisher_seq_summary.csv", stringsAsFactors = F)
# colnames(plot_data) <- c("year", "New work", "Stable publisher", "Return of earlier publisher",
#                          "New publisher, old publisher inactive", "New publisher, old publisher active")

plot_data$decade <- floor(plot_data$pubyear / 10) * 10
decdata <- aggregate(plot_data["new_work"], by=plot_data['decade'], sum)
decdata$stable <- aggregate(plot_data['stable'], by=plot_data['decade'], sum)$stable
decdata$return_of_earlier_publisher <- aggregate(plot_data['return_of_earlier_publisher'], by=plot_data['decade'], sum)$return_of_earlier_publisher
decdata$new_publisher_old_inactive <- aggregate(plot_data["new_publisher_old_inactive"], by=plot_data['decade'], sum)$new_publisher_old_inactive
decdata$new_publisher <- aggregate(plot_data["new_publisher"], by=plot_data['decade'], sum)$new_publisher
colnames(decdata) <- c("decade", "New work", "Stable publisher", "Return of earlier publisher",
                         "New publisher, old inactive", "New publisher, old active")

# make plot data "tidy" for ggplot and wiggle stuff around types for some obscure reason
molten_plot_data <- melt(decdata, id.vars = "decade", variable.name = "Category")
molten_plot_data$Category <- as.character(molten_plot_data$Category)
molten_plot_data$Category <- factor(molten_plot_data$Category, levels =
  c("New publisher, old active", "New publisher, old inactive",
    "Return of earlier publisher", "Stable publisher", "New work"))

# create plot
plot <- ggplot(molten_plot_data, aes(x=decade, y=value, fill=Category)) +
  geom_area(position="fill") + 
  theme_comhis(type="discrete") +
  theme(legend.position = "bottom") +
  theme(legend.title = element_blank()) +
  guides(fill = guide_legend(nrow=3,byrow=TRUE)) +
  scale_y_continuous(labels = percent, breaks = seq(0, 1, 0.1)) +
  scale_x_continuous(breaks = seq(1450, 1800, 50)) +
  labs(y = "Share (%)", x = "Decade")

# check plot in R Studio
plot

# save plot
save_plot_image(plot, plotname = "fig12_all_publisher_seq_summary", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "png", width=23, height=15)
save_plot_image(plot, plotname = "fig12_all_publisher_seq_summary", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=23, height=15)
