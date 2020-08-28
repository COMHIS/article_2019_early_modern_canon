require("ggplot2")
require("ggthemes")
library("dplyr")
library("reshape2")
library("gridExtra")

source("commonlibs_r/theme_comhis.R")
source("commonlibs_r/output.R")

plotdata <- read.csv("../data/work/canon_individual_publisher_counts_subject_topics_all.csv", stringsAsFactors = F)

# massage data to sensible format
plotdata$total_n <- plotdata$canon_n + plotdata$non_canon_n
plotdata_f <- plotdata[which(plotdata$total_n > 49),]
plotdata_f <- subset(plotdata_f, select=c(
  actor_id,
  canon_ratio,
  subject_topic_simple_counts.Natural.science...mathematics,
  subject_topic_simple_counts.Information...general.works,
  subject_topic_simple_counts.The.arts,
  subject_topic_simple_counts.History...geography,
  subject_topic_simple_counts.Philosophy,
  subject_topic_simple_counts.Applied.science,
  subject_topic_simple_counts.Social.sciences,
  subject_topic_simple_counts.Language,
  subject_topic_simple_counts.Religion,
  subject_topic_simple_counts.Literature,
  subject_topic_simple_counts.uncategorized,
  subject_topic_simple_counts.total_discounting_uncategorized,
  subject_topic_simple_percentages.Natural.science...mathematics,
  subject_topic_simple_percentages.Information...general.works,
  subject_topic_simple_percentages.The.arts, 
  subject_topic_simple_percentages.History...geography,
  subject_topic_simple_percentages.Philosophy,
  subject_topic_simple_percentages.Applied.science,
  subject_topic_simple_percentages.Social.sciences,
  subject_topic_simple_percentages.Language,
  subject_topic_simple_percentages.Religion,
  subject_topic_simple_percentages.Literature,
  subject_topic_simple_percentages.uncategorized))
colnames(plotdata_f) <- c(
  "actor_id",
  "canon_ratio",
  "st_counts Natural science, mathematics",
  "st_counts Information, general works",
  "st_counts The arts",
  "st_counts History and geography",
  "st_counts Philosophy",
  "st_counts Applied science",
  "st_counts Social sciences",
  "st_counts Language",
  "st_counts Religion",
  "st_counts Literature",
  "st_counts uncategorized",
  "st_counts total_discounting_uncategorized",
  "st_percentages Natural science, mathematics",
  "st_percentages Information, general works",
  "st_percentages The arts", 
  "st_percentages History and geography",
  "st_percentages Philosophy",
  "st_percentages Applied science",
  "st_percentages Social sciences",
  "st_percentages Language",
  "st_percentages Religion",
  "st_percentages Literature",
  "st_percentages uncategorized"
)

plotdata_canon_ratios <- plotdata_f[, c("actor_id", "canon_ratio")]
plotdata_st_counts <- plotdata_f[, c("actor_id",
                                     "st_counts Natural science, mathematics",
                                     "st_counts Information, general works",
                                     "st_counts The arts",
                                     "st_counts History and geography",
                                     "st_counts Philosophy",
                                     "st_counts Applied science",
                                     "st_counts Social sciences",
                                     "st_counts Language",
                                     "st_counts Religion",
                                     "st_counts Literature")]
plotdata_st_counts_molten <- melt(plotdata_st_counts, id.vars = "actor_id", variable.name = "st")
plotdata_st_counts_molten$st <- as.character(plotdata_st_counts_molten$st)
plotdata_st_counts_molten$st <- substr(plotdata_st_counts_molten$st, 11, nchar(plotdata_st_counts_molten$st))
colnames(plotdata_st_counts_molten) <- c("actor_id", "st", "count")

plotdata_st_percentages <- plotdata_f[, c("actor_id",
                                          "st_percentages Natural science, mathematics",
                                          "st_percentages Information, general works",
                                          "st_percentages The arts", 
                                          "st_percentages History and geography",
                                          "st_percentages Philosophy",
                                          "st_percentages Applied science",
                                          "st_percentages Social sciences",
                                          "st_percentages Language",
                                          "st_percentages Religion",
                                          "st_percentages Literature")]
plotdata_st_percentages_molten <- melt(plotdata_st_percentages, id.vars = "actor_id", variable.name = "st")
plotdata_st_percentages_molten$st <- as.character(plotdata_st_percentages_molten$st)
plotdata_st_percentages_molten$st <- substr(plotdata_st_percentages_molten$st, 16, nchar(plotdata_st_percentages_molten$st))
colnames(plotdata_st_percentages_molten) <- c("actor_id", "st", "st_ratio")

plotdata_joined <- merge(plotdata_st_percentages_molten, plotdata_st_counts_molten)
plotdata_joined <- merge(plotdata_joined, plotdata_canon_ratios)

# save plot data
write.csv(plotdata_joined, "../output/data/fig13_data.csv", row.names = F)

# draw plot.
plot <- ggplot(plotdata_joined, aes(x=st_ratio, y=canon_ratio, size=count, color=st)) +
  geom_point() +
  facet_wrap(facets=vars(st), nrow=2, ncol=5) +
  scale_y_continuous(labels = percent, breaks = seq(0, 1, 0.25)) +
  scale_x_continuous(labels = percent, breaks = seq(0, 0.75, 0.25)) +
  labs(y="Canon / all titles", x="Subject topic / all titles") +
  theme_comhis(type="discrete", base_size = 12) +
  theme(legend.position = "none") +
  coord_fixed(ratio=1) +
  theme(strip.text.x = element_text(size = 8, color = "black"),
        strip.text.y = element_text(size = 8, color = "black"),
        strip.background = element_rect(color="black", fill="white", size=0.25, linetype="solid"))
  # theme(axis.text.x = element_text(angle = -90))
  # theme(panel.spacing.x = unit(6, "mm"))
  # theme(axis.text.y = element_text(angle = -45))

# test plot in r studio
plot

save_plot_image(
  plot, plotname = "fig13_publisher_subject_topics", outputdir = "../output/figures/",
  size_preset = "custom", file_format = "png", width=24, height=15)
save_plot_image(
  plot, plotname = "fig13_publisher_subject_topics", outputdir = "../output/figures/",
  size_preset = "custom", file_format = "eps", width=24, height=15)

