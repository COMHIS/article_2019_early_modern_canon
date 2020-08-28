# Manual fixes
ws1$big_pubs <- gsub("TONSON, Richard", "Tonson, Jacob", ws1$big_pubs)
ws1$big_pubs <- factor(ws1$big_pubs, levels = c(sort(setdiff(ws1$big_pubs, "Other/Unknown")), "Other/Unknown"))

# Ensure that Other/Unknown category is gray
cols <- gdocs_pal()(length(unique(ws1$big_pubs)))
names(cols) <- as.character(levels(ws1$big_pubs))
cols[which(names(cols) == "Other/Unknown")] <- "darkgray"

fig <- ggplot(data = ws1, aes(y = short, x = publication_decade, colour = big_pubs, size = f)) +
  geom_count() +
  theme_comhis(type="discrete", base_size=12) +
  scale_color_manual(values = cols) + 
  labs(x = "Decade",
       y = ""
       #title = paste("Shakespeare")
       ) +
  guides(color = guide_legend(title = ""), size = guide_legend(title = "Share")) +
  scale_size_continuous(label = scales::percent_format(accuracy = 10L))
  #scale_size_continuous(breaks = seq(2, 10, 2))  
  #scale_y_discrete(labels = ws1[match(levels(ws1$finalWorkField), ws1$finalWorkField), "short"]) 

save_plot_image(fig, plotname = "fig8", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=12)
