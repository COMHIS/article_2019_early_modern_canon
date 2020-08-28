fig <- ggplot(df, aes(x = decade_death, y = f.postmortem.nyears)) +
       geom_point() +
       geom_smooth(method = "lm", color = "black") +
       geom_abline(aes(intercept = 1, slope = -.1)) +
       labs(x = "Decade", # Author death
            y = "Frequency (%)") + # Authors with
       theme_comhis(type="continuous", base_size = 15) +
       scale_y_continuous(label = scales::percent)

save_plot_image(fig, plotname = "fig6", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=9, height=9)
