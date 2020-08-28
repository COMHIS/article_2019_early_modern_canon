fig <- ggplot(af, aes(x = publication_decade, y = f, fill = cats))  + 
  geom_bar(stat = "identity", colour="black", position=position_fill()) +
  theme_comhis(type="discrete") +  
  scale_x_continuous(limits=c(min(af$publication_decade), 1800)) +
  scale_y_continuous(label = scales::percent) +
  guides(fill = guide_legend(title = "")) + 
  labs(x = "Decade",
       y = "Share (%)",
       title = "")
       #title = paste("top-5 categories of canon, works published each decade"))       

save_plot_image(fig, plotname = "fig5", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=12)
