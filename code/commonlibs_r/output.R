library(ggplot2)

save_plots_png <- function(plots, prefix, outputdir = "output/figures/", size_preset = "small") {
  plot_filename_prefix <- paste0(prefix, "_", Sys.Date(), "_")
  
  if (size_preset == "small") {
    preset_width <- 6
    preset_height <- 4
    preset_dpi <- 300
  } else {
    preset_width <- 7
    preset_height <- 4
    preset_dpi <- 300
  }
  
  
  for (item in 1:length(plots)) {
    filename <- paste0(outputdir,
                       plot_filename_prefix,
                       names(plots)[item],
                       ".png")
    ggsave(filename, plots[[item]],
           width = preset_width,
           height = preset_height,
           dpi = preset_dpi)  
  }
}


save_plot_image <- function(plot, plotname, outputdir = "../output/figures/", size_preset = "small", file_format="png", width=7, height=4) {

  if (size_preset == "small") {
    preset_width <- 6
    preset_height <- 4
    preset_dpi <- 300
  } else if (size_preset == "xlarge") {
    preset_width <- 12
    preset_height <- 8
    preset_dpi <- 300
  } else {
    preset_width <- width
    preset_height <- height
    preset_dpi <- 300
  }
  filename <- paste0(outputdir,
                     plotname,
                     ".", file_format)

  # print(preset_height)

  ggsave(filename = filename,
         plot = plot,
         width = preset_width,
         height = preset_height,
         dpi = preset_dpi,
         device = file_format,
	 units = "cm" # Units is needed to ensure that the fig width and height follow publishing col width standards
	              # 90 / 140 / 190 mm for 1 / 1.5 / 2 columns
	 )
}
