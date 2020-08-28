pics <- list()
legends <- list()

gats <- c("2fo", "4to", "8vo", "12mo")

#for (this.work in head(as.character(div$work), 16)) {
for (this.work in top.works) {

    dsub <- d %>% dplyr::filter(work %in% this.work) 
    dsub$gatherings <- droplevels(factor(dsub$gatherings, levels = gats))

    this.title <- this.work
    
    this.title <- gsub("11-short introduction of grammar", "Short intro. of grammar", this.title)
    this.title <- gsub("13-aesops fables", "Aesop's fables", this.title)
    this.title <- gsub("18-paradise lost poem in twelve books", "Paradise lost poem", this.title)        

    cols <- unname(default_colors("gatherings")[tolower(map_gatherings(levels(dsub$gatherings)))])

    p <- dsub %>% 
           ggplot(aes(x = publication_decade,
	              y = N,
		      color = gatherings
		      )) + 
             geom_point() + 
	     scale_color_manual(values = cols) +
	     scale_x_continuous(limits = c(min(d$publication_decade), max(d$publication_decade))) +
	     labs(
	 title = paste(this.title),
		   x = "Decade",
		   y = "") +
         guides(size="none") +
         guides(color = guide_legend(title = "Gatherings"))	 

    p <- p + theme_comhis(type="continuous", base_size=12, family="Helvetica")

    # Pick the legend (same for all pics)
    legends[[this.work]] <- get_legend(p)
  
    # print(p)
    # Remove the legend from individual pics
    pics[[this.work]] <- p + guides(color = "none", size="none")

}

library(cowplot)
maxx <- max(d$N)
p <- plot_grid(
       pics[[1]] + labs(y = "Title count (N)") + scale_y_continuous(limits = c(0, maxx)), 
       pics[[2]] + scale_y_continuous(limits = c(0, maxx)), 
       pics[[3]] + scale_y_continuous(limits = c(0, maxx)),
       nrow = 1)

fig <- plot_grid(p, legends[[2]], rel_widths = c(15, 3))

save_plot_image(fig, plotname = "fig20", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=24, height=6)



