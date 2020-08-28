fig <- ggplot(yy72, aes(x = publication_decade, y = n))  + 
  geom_bar(stat = "identity") +
  theme_comhis(type="discrete", base_size=15) +    
  scale_x_continuous(limits=c(min(yy72$publication_decade), 1800)) +
  labs(x = "Decade",
       y = "Works (N)",
       title = paste(""))
       # Title: Female publications in canon
       
save_plot_image(fig, plotname = "fig14", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=9, height=9)

