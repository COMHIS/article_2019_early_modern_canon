require("ggplot2")
require("ggthemes")
library("dplyr")
library("reshape2")
library("scales")

source("commonlibs_r/theme_comhis.R")
source("commonlibs_r/output.R")

plotdata <- read.csv("../output/data/fig9_actors_missing_in_category.csv", stringsAsFactors = F)

# create plot
plot <- ggplot(plotdata, aes(x=decade)) +
  geom_line(aes(y = items_with_no_publishers_per_all_editions, colour="Publishers", linetype="All ESTC")) + 
  geom_line(aes(y = items_with_no_printers_per_all_editions, colour="Printers", linetype="All ESTC")) +
  geom_line(aes(y = items_with_no_booksellers_per_all_editions, colour="Booksellers", linetype="All ESTC")) +
  geom_line(aes(y = canon_no_pub, colour="Publishers", linetype="Canon")) +
  geom_line(aes(y = canon_no_pri, colour="Printers", linetype="Canon")) +
  geom_line(aes(y = canon_no_sel, colour="Booksellers", linetype="Canon")) +
  theme_comhis(type="discrete") +
  scale_colour_manual(values = c(gdocs_pal()(3))) +
  scale_linetype_manual(values = c(1, 2)) +
  labs(y="Title share (%)", x="Decade") +
  scale_y_continuous(labels = percent) +
  theme(legend.title=element_blank())

# check plot in R Studio
# plot

# save fig
save_plot_image(plot, plotname = "fig9_actors_missing_in_category", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=10)
save_plot_image(plot, plotname = "fig9_actors_missing_in_category", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "png", width=19, height=10)
