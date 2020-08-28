fig <- ggplot(df, aes(x = decade, y = f, color = genre, fill = genre)) +
       geom_point() +
       geom_smooth() +
       theme_comhis(type="discrete", base_size = 12) +         
       scale_y_continuous(label = scales::percent) +
       labs(x = "Decade", y = "Share (%)") +
       guides(color = guide_legend(title = ""),
               fill = guide_legend(title = "")) +
       theme(legend.position=c(0.85, 0.78),
              legend.background = element_rect(fill="transparent")) 


save_plot_image(fig, plotname = "fig4", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=12)


