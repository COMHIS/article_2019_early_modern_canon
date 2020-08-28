genres <- setdiff(na.omit(unique(df$simplified_dd_subject)), "")
pics <- list()
legends <- list()

# Colors for gatherings
colors <- default_colors("gatherings_short")

for (ca in genres) {

  dfs <- df %>% filter(simplified_dd_subject == ca)
  gathering_colors <- colors[tolower(levels(dfs$gatherings))]
  names(gathering_colors) <- capitalize(names(gathering_colors))

  p <- dfs %>%
    ggplot(aes(x = publication_decade, y = f, fill = gatherings)) +
      geom_bar(stat = "identity", position = "stack", color = "black", size = .01) +
      theme_comhis(type="continuous", base_size=10) +
      scale_y_continuous(label = scales::percent) +
      scale_x_continuous(limits = range(df$publication_decade),
                         breaks = seq(1500, 1800, 100)) +      
      scale_fill_manual(values = gathering_colors) + 
      labs(title = ca,
           x = "Decade",
	   y = "") +
      guides(fill = guide_legend(title = "Gatherings")) 


  # Pick the legend (same for all pics)
  legends[[ca]] <- get_legend(p)

  # Remove the legend from individual pics
  pics[[ca]] <- p + guides(fill = "none")

}


library(cowplot)
p <- plot_grid(
       pics[[1]] + labs(y = "Gatherings (%)", x = ""),
         pics[[2]] + labs(x = ""),
         pics[[3]] + labs(x = ""),	 
       pics[[4]] + labs(y = "Gatherings (%)"),
         pics[[5]] + labs(x = ""),
         pics[[6]] + labs(x = ""),	 
       pics[[7]] + labs(y = "Gatherings (%)"),
         pics[[8]] + labs(x = ""),
         pics[[9]] + labs(x = ""),	        
       pics[[10]] + labs(y = "Gatherings (%)"),
         pics[[11]] + labs(x = ""),
         pics[[12]] + labs(x = ""),	        	 
       pics[[13]] + labs(y = "Gatherings (%)"),
         pics[[14]] + labs(x = ""),
         pics[[15]] + labs(x = ""),	        	 	 
       pics[[16]] + labs(y = "Gatherings (%)"),
         pics[[17]], legends[[1]], # pics[[18]],	 
	 nrow = 6)

fig <- p
#fig <- plot_grid(p, legends[[1]], rel_widths = c(21, 4))

save_plot_image(fig, plotname = "fig19", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=25)		

