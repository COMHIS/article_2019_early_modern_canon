## print plot
fig <- ggplot(data = yo, aes(y = finalWorkField, x = publication_decade)) + 
  geom_count(breaks=seq(1450, 1800, by=25), limits=c(min(yo$publication_decade), 1800)) +
  theme_comhis(type="continuous", base_size=15) +
  #theme(legend.position="none") +
  theme(legend.position=c(0.15, 0.82), legend.background = element_rect(fill="transparent")) +  
  labs(x = "Decade",
       y = "",
       title = paste("")       
       ) +
  scale_y_discrete(labels =  yo[match(levels(yo$finalWorkField), yo$finalWorkField), "short"]) +
  scale_x_continuous(breaks=seq(1500, 1800, by=50), limits=c(min(yo$publication_decade), 1800))


save_plot_image(fig, plotname = "fig3", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=14)