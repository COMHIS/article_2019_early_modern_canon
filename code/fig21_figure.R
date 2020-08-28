p <- d %>% 
           ggplot(aes(x = publication_decade,
	              y = paper,
		      color = gatherings
		      )) + 
             geom_point() +
             geom_line() +	     
	     scale_color_manual(values = unname(default_colors("gatherings")[tolower(map_gatherings(levels(d$gatherings)))])) +
	     scale_x_continuous(limits = c(min(d$publication_decade), max(d$publication_decade))) +
	     labs(
	 title = "",
		   x = "Decade",
		   y = "") +
         guides(size="none") +
         guides(color = guide_legend(title = "Gatherings"))	 

    p <- p + theme_comhis(type="continuous", base_size=12, family="Helvetica")

    p <- p + guides(size="none") +
             #labs(y = "Title count (N)") +
             labs(y = "Paper consumption (sheets)") +	     
	     scale_y_log10() + 
	     theme(legend.position = c(0.8, 0.25))
	     #scale_y_continuous(limits = c(0, 100))	     

# Exponential notation for axis labels
require(scales)
p <- p + scale_y_continuous(trans = log10_trans(),
    breaks = trans_breaks("log10", function(x) 10^x),
    labels = trans_format("log10", math_format(10^.x)))

p

save_plot_image(p, plotname = "fig21", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=12, height=10)



