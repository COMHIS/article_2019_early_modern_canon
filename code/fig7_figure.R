library(comhis)
fig <- ggplot(df, aes(x = publication_year,
                      y = name_unified,
		      color = name_unified)) + 
          geom_count(aes(color = mygreatfactor)) +
  	  theme_comhis(type="discrete", base_size = 15) +	  
	  labs(x = "Decade",
	       y = "", 
	       title = "" # Post-Mortem Publications
	       ) +
	  # scale_color_manual(values = c("darkgray", "black")) +
  	  scale_x_continuous(limits=c(min(df$publication_year), 1800),
                     breaks=seq(1500, 1800, 50)) +	  
          #guides(color = guide_legend(title = "Publication time")) +
	  scale_color_manual(name = "Publication time",
	                       labels = c("Lifetime", "Posthumous"),
			       values = c("red", "blue")) +
          guides(size = "none") #+
	  #theme(legend.position = c(0.1, 0.9),
	  #      legend.background = element_rect(fill="transparent")) 



save_plot_image(fig, plotname = "fig7", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=22, height=15)

save_plot_image(fig, plotname = "fig7", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "jpeg", width=22, height=15)

