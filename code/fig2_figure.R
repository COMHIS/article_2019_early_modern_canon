# Timeline of top works
fig <- ggplot(data = yo, aes(y = short, x = publication_year)) + 
  geom_count(size = 1) +
  scale_x_continuous(breaks=seq(1500, 1800, by=50), limits=c(1500, 1800)) + 
  labs(x = "Decade", y = "Works")  + 
  theme_comhis(type="continuous") +
  theme(axis.text.y=element_blank(),
        axis.ticks.y=element_blank()) +
  guides(size = "none") #+ 
  # grids(linetype = "dashed") 	

save_plot_image(fig, plotname = "fig2", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=19)

