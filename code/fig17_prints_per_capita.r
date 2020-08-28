#Load data

source("commonlibs_r/output.R")

library(bibliographica)
library(ggplot2)
library(gridExtra)

#THIS FILE IS CREATED BY FIG 16 SCRIPT!
works_places <- read.csv("../data/work/works_places.csv", stringsAsFactors = FALSE)

canon <- read.csv("../data/work/canon.csv", stringsAsFactors = FALSE)
canon_titles <- canon$work_titles[which(canon$is_canon == TRUE)]

#THIS FILE IS CREATED BY HAND (ON GOOGLE DRIVE) - SOME SOURCES LISTED BELOW
hist_pop <- read.csv("../data/work/historic_pop.csv",stringsAsFactors = FALSE)
canon_work_places <- works_places[which(works_places$finalWorkField %in% canon$work_titles[which(canon$is_canon == TRUE)]),]

# Sources for historic population info: 
#http://www.visionofbritain.org.uk/census/GB1841ABS_1/6
#https://en.wikipedia.org/wiki/List_of_towns_and_cities_in_England_by_historical_population
#http://www.edinphoto.org.uk/1_edin/1_edinburgh_history_-_dates_population.htm
#https://www.british-history.ac.uk/vch/oxon/vol4/pp74-180
#https://books.google.co.uk/books?id=edQoDwAAQBAJ&pg=PA88&lpg=PA88&dq=dublin+population+1750&source=bl&ots=P_G-j_RiGs&sig=ACfU3U1O-7ZmkGNEoZIo5iMjsrA8o2ZJTg&hl=en&sa=X&ved=2ahUKEwjMufeg9NniAhWG1uAKHWkWC1U4ChDoATACegQICRAB#v=onepage&q=dublin%20population%201750&f=false



#1700
subset1700 <- works_places[c(intersect(which(works_places$publication_year > 1695), which(works_places$publication_year < 1706))),]
subset1700 <- subset1700[which(subset1700$finalWorkField %in% canon_titles),]
subset1700_df <- data.frame(table(subset1700$publication_place), stringsAsFactors = FALSE)
subset1700_df$pop <- 0

subset1700_df <- subset1700_df[c(which(subset1700_df$Var1 %in% hist_pop$X)),]

for(i in 1:nrow(subset1700_df)) {
  subset1700_df$pop[i] <- hist_pop$X1700[which(hist_pop$X == subset1700_df$Var1[i])]
}

subset1700_df$ratio <- subset1700_df$Freq/subset1700_df$pop
subset1700_df <- subset1700_df[order(-subset1700_df$ratio),]
#barplot(subset1700_df$ratio, names.arg = subset1700_df$Var1, las = 2)

#1750
subset1750 <- works_places[c(intersect(which(works_places$publication_year > 1745), which(works_places$publication_year < 1756))),]
subset1750 <- subset1750[which(subset1750$finalWorkField %in% canon_titles),]
subset1750_df <- data.frame(table(subset1750$publication_place), stringsAsFactors = FALSE)
subset1750_df$pop <- 0

subset1750_df <- subset1750_df[c(which(subset1750_df$Var1 %in% hist_pop$X)),]

for(i in 1:nrow(subset1750_df)) {
  subset1750_df$pop[i] <- hist_pop$X1750[which(hist_pop$X == subset1750_df$Var1[i])]
}

subset1750_df$ratio <- subset1750_df$Freq/subset1750_df$pop
subset1750_df <- subset1750_df[order(-subset1750_df$ratio),]
#barplot(subset1750_df$ratio, names.arg = subset1750_df$Var1, las = 2)

#1800
subset1800 <- works_places[c(intersect(which(works_places$publication_year > 1795), which(works_places$publication_year < 1806))),]
subset1800 <- subset1800[which(subset1800$finalWorkField %in% canon_titles),]
subset1800_df <- data.frame(table(subset1800$publication_place), stringsAsFactors = FALSE)
subset1800_df$pop <- 0

subset1800_df <- subset1800_df[c(which(subset1800_df$Var1 %in% hist_pop$X)),]

for(i in 1:nrow(subset1800_df)) {
  subset1800_df$pop[i] <- hist_pop$X1800[which(hist_pop$X == subset1800_df$Var1[i])]
}

subset1800_df$ratio <- subset1800_df$Freq/subset1800_df$pop
subset1800_df <- subset1800_df[order(-subset1800_df$ratio),]
#barplot(subset1800_df$ratio, names.arg = subset1800_df$Var1, las = 2)

#NOT JUST CANON

#1700
subset1700_nc <- works_places[c(intersect(which(works_places$publication_year > 1695), which(works_places$publication_year < 1706))),]
subset1700_nc_df <- data.frame(table(subset1700_nc$publication_place), stringsAsFactors = FALSE)
subset1700_nc_df$pop <- 0

subset1700_nc_df <- subset1700_nc_df[c(which(subset1700_nc_df$Var1 %in% hist_pop$X)),]

for(i in 1:nrow(subset1700_nc_df)) {
  subset1700_nc_df$pop[i] <- hist_pop$X1700[which(hist_pop$X == subset1700_nc_df$Var1[i])]
}

subset1700_nc_df$ratio <- subset1700_nc_df$Freq/subset1700_nc_df$pop
subset1700_nc_df <- subset1700_nc_df[order(-subset1700_nc_df$ratio),]
#barplot(subset1700_nc_df$ratio, names.arg = subset1700_nc_df$Var1, las = 2)

#1750
subset1750_nc <- works_places[c(intersect(which(works_places$publication_year > 1745), which(works_places$publication_year < 1756))),]
subset1750_nc_df <- data.frame(table(subset1750_nc$publication_place), stringsAsFactors = FALSE)
subset1750_nc_df$pop <- 0

subset1750_nc_df <- subset1750_nc_df[c(which(subset1750_nc_df$Var1 %in% hist_pop$X)),]

for(i in 1:nrow(subset1750_nc_df)) {
  subset1750_nc_df$pop[i] <- hist_pop$X1750[which(hist_pop$X == subset1750_nc_df$Var1[i])]
}

subset1750_nc_df$ratio <- subset1750_nc_df$Freq/subset1750_nc_df$pop
subset1750_nc_df <- subset1750_nc_df[order(-subset1750_nc_df$ratio),]
#barplot(subset1750_nc_df$ratio, names.arg = subset1750_nc_df$Var1, las = 2)

#1800
subset1800_nc <- works_places[c(intersect(which(works_places$publication_year > 1795), which(works_places$publication_year < 1806))),]
subset1800_nc_df <- data.frame(table(subset1800_nc$publication_place), stringsAsFactors = FALSE)
subset1800_nc_df$pop <- 0

subset1800_nc_df <- subset1800_nc_df[c(which(subset1800_nc_df$Var1 %in% hist_pop$X)),]

for(i in 1:nrow(subset1800_nc_df)) {
  subset1800_nc_df$pop[i] <- hist_pop$X1800[which(hist_pop$X == subset1800_nc_df$Var1[i])]
}

subset1800_nc_df$ratio <- subset1800_nc_df$Freq/subset1800_nc_df$pop
subset1800_nc_df <- subset1800_nc_df[order(-subset1800_nc_df$ratio),]
#barplot(subset1800_nc_df$ratio, names.arg = subset1800_nc_df$Var1, las = 2)




#$mar
#[1] 5.1 4.1 4.1 2.1


# Plot

# par(mar=c(5.1,4.1,4.1,2.1))
# par(mfrow=c(3,2))
# barplot(subset1700_df$ratio, names.arg = subset1700_df$Var1, las = 2, main = "Canon: 1700, 1750, 1800")
# barplot(subset1700_nc_df$ratio, names.arg = subset1700_nc_df$Var1, las = 2, main = "All ESTC: 1700, 1750, 1800")
# barplot(subset1750_df$ratio, names.arg = subset1750_df$Var1, las = 2)
# barplot(subset1750_nc_df$ratio, names.arg = subset1750_nc_df$Var1, las = 2)
# #par(mar=c(8.1,4.1,4.1,2.1))
# barplot(subset1800_df$ratio, names.arg = subset1800_df$Var1, las = 2)
# barplot(subset1800_nc_df$ratio, names.arg = subset1800_nc_df$Var1, las = 2)
# par(mfrow=c(1,1))
# #par(mar=c(5.1,4.1,4.1,2.1))

#theme_set(theme_bw(20))
source("commonlibs_r/theme_comhis.R") # theme_comhis
#install_github("COMHIS/bibliographica")


data_locs <- c("subset1700_df", "subset1750_df", "subset1800_df",
               "subset1700_nc_df", "subset1750_nc_df", "subset1800_nc_df")

#correct city names
for (i in 1:6) {
  temp_data <- get(paste0(data_locs[i]))
  temp_data$Var1 <- gsub("Philadelphia Pa", "Philadelphia", temp_data$Var1)
  temp_data$Var1 <- gsub("New York NY", "New York", temp_data$Var1)
  temp_data$Var1 <- gsub("Boston Ma", "Boston MA", temp_data$Var1)
  if(nrow(temp_data) > 9) {
    temp_data <- temp_data[1:10,]
  }
  assign(data_locs[i], temp_data)
}


#order levels for plots
subset1700_df$Var1 <- factor(subset1700_df$Var1, levels = (subset1700_df$Var1[
  which(subset1700_df$ratio == sort(subset1700_df$ratio, decreasing = TRUE))]))
subset1750_df$Var1 <- factor(subset1750_df$Var1, levels = (subset1750_df$Var1[
  which(subset1750_df$ratio == sort(subset1750_df$ratio, decreasing = TRUE))]))
subset1800_df$Var1 <- factor(subset1800_df$Var1, levels = (subset1800_df$Var1[
  which(subset1800_df$ratio == sort(subset1800_df$ratio, decreasing = TRUE))]))
subset1700_nc_df$Var1 <- factor(subset1700_nc_df$Var1, levels = (subset1700_nc_df$Var1[
  which(subset1700_nc_df$ratio == sort(subset1700_nc_df$ratio, decreasing = TRUE))]))
subset1750_nc_df$Var1 <- factor(subset1750_nc_df$Var1, levels = (subset1750_nc_df$Var1[
  which(subset1750_nc_df$ratio == sort(subset1750_nc_df$ratio, decreasing = TRUE))]))
subset1800_nc_df$Var1 <- factor(subset1800_nc_df$Var1, levels = (subset1800_nc_df$Var1[
  which(subset1800_nc_df$ratio == sort(subset1800_nc_df$ratio, decreasing = TRUE))]))


# #order levels for plots - TO REVERSE ORDER
# subset1700_df$Var1 <- factor(subset1700_df$Var1, levels = rev(subset1700_df$Var1[
#   which(subset1700_df$ratio == sort(subset1700_df$ratio, decreasing = TRUE))]))
# subset1750_df$Var1 <- factor(subset1750_df$Var1, levels = rev(subset1750_df$Var1[
#   which(subset1750_df$ratio == sort(subset1750_df$ratio, decreasing = TRUE))]))
# subset1800_df$Var1 <- factor(subset1800_df$Var1, levels = rev(subset1800_df$Var1[
#   which(subset1800_df$ratio == sort(subset1800_df$ratio, decreasing = TRUE))]))
# subset1700_nc_df$Var1 <- factor(subset1700_nc_df$Var1, levels = rev(subset1700_nc_df$Var1[
#   which(subset1700_nc_df$ratio == sort(subset1700_nc_df$ratio, decreasing = TRUE))]))
# subset1750_nc_df$Var1 <- factor(subset1750_nc_df$Var1, levels = rev(subset1750_nc_df$Var1[
#   which(subset1750_nc_df$ratio == sort(subset1750_nc_df$ratio, decreasing = TRUE))]))
# subset1800_nc_df$Var1 <- factor(subset1800_nc_df$Var1, levels = rev(subset1800_nc_df$Var1[
#   which(subset1800_nc_df$ratio == sort(subset1800_nc_df$ratio, decreasing = TRUE))]))



titles <- c("Canon 1700", "Canon 1750", "Canon 1800",
            "All ESTC 1700", "All ESTC 1750", "All ESTC 1800")

# Convert ratios to percent scale before plotting (to avoid decimals)

for (i in 1:6) {
  temp_data <- get(paste0(data_locs[i]))
  temp_data$ratio <- 100 * temp_data$ratio  
  temp_fig <- ggplot(data=temp_data, aes(Var1, y = ratio)) +
    geom_bar(stat = "identity") +
    coord_flip()+
    labs(x = "",
         y = "Title count per capita (%)",
         title = titles[i]) +
    guides(color = guide_legend(title = "", reverse = FALSE)) +
    guides(fill = "none") +  
    theme_comhis(type="continuous", base_size=14) +
    scale_color_manual(values = c("darkred", "darkblue", "black")) +
    scale_x_discrete(limits = rev(levels(temp_data$Var1))) #+ 
  assign(paste0("fig_", i), temp_fig)

}

#to_save <- arrangeGrob(fig_1 + labs(x = "", y = ""), fig_4 + labs(x = "", y = ""),
#                       fig_2 + labs(x = "", y = ""), fig_5 + labs(x = "", y = ""),#
#		       fig_3, fig_6,
#		       ncol=2)

library(cowplot)
to_save <- plot_grid(fig_1 + labs(x = "", y = ""),
                         fig_4 + labs(x = "", y = ""),
                     fig_2 + labs(x = "", y = "") + scale_y_continuous(breaks = seq(0, 0.9, 0.3)),
		         fig_5 + labs(x = "", y = ""),
		     fig_3,
		         fig_6,
		       ncol=2)

save_plot_image(to_save, plotname = "fig17", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=19)

