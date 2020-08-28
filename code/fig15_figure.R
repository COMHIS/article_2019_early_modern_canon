
fig <- ggplot(af, aes(x = publication_decade, y = f, fill = publoc))  + 
  geom_bar(stat = "identity", colour="black", position=position_fill()) +
  theme_comhis(type="discrete") +  
  scale_x_continuous(#limits=c(min(af$publication_decade), 1800),
                     breaks=seq(1500, 1800, 100)) +
  scale_y_continuous(labels = scales::percent) +  
  labs(x = "Decade",
       y = "Share (%)") + # Title: Summary of places (London excluded)
  guides(fill = guide_legend(title = ""))

save_plot_image(fig, plotname = "fig15", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=10)