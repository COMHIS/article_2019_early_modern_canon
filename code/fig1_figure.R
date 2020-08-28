g2 <- g1 %>% group_by(data, publication_year) %>%
             dplyr::summarise(n = n())
g2$data <- factor(g2$data, levels = c("Canon", "Unique works", "ESTC"))

fig <- ggplot(data=g2, aes(publication_year, y = n, color = data)) + 
  #geom_bar(position = 'dodge', stat='count', colour="black", width = 20) +
  #geom_line(aes(colour=data, y=n)) +
  geom_smooth(fill = "white") +  
  geom_point() +    
  labs(x = "Year",
       y = "Title count (n)",
       title = paste("")) + # 
  scale_x_continuous(breaks=seq(1500, 1800, by=50), limits=c(1500, 1800)) + 
  guides(color = guide_legend(title = "", reverse = TRUE)) +
  guides(fill = "none") +  
  theme_comhis(type="continuous") +
  scale_color_manual(values = c("darkred", "darkblue", "black")) +
  theme(legend.position = c(0.2, 0.93), legend.background = element_rect(fill="transparent")) 

# Caption
# ESTC / Unique works (author known / Canon
# "ESTC/483k", "Unique_works/200k", "Canon/34k"

# save plot
save_plot_image(fig, plotname = "fig1", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=19)

