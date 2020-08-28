#Libraries


source("commonlibs_r/output.R")
source("commonlibs_r/theme_comhis.R")

library(bibliographica)
library(ggplot2)


#Load data

works_places <- read.csv("../data/work/works_places.csv", stringsAsFactors = FALSE)
canon <- read.csv("../data/work/canon.csv", stringsAsFactors = FALSE)
canon_titles <- canon$work_titles[which(canon$is_canon == TRUE)]
hist_pop <- read.csv("../data/work/historic_pop.csv",stringsAsFactors = FALSE)
canon_work_places <- works_places[which(works_places$finalWorkField %in% canon$work_titles[which(canon$is_canon == TRUE)]),]

cities_df <- data.frame(years = c(1500:1800))
cities_df$glasgow <- 0
cities_df$edinburgh <- 0
cities_df$dublin <- 0
cities_df$london <- 0
cities_df$cambridge <- 0
cities_df$oxford <- 0
cities_df$boston <- 0
cities_df$total <- 0

cities <- c("Glasgow", "Edinburgh", "Dublin", "London", "Cambridge", "Oxford", "Boston Ma")
for(i in 1:nrow(cities_df)) {
  cat("\r", i)
  year <- i + 1499
  for(x in 1:length(cities)) {
    cities_df[i,x+1] <- length(intersect(which(canon_work_places$publication_place == cities[x]),which(canon_work_places$publication_year == year)))
  }
  cities_df$total[i] <- length(which(canon_work_places$publication_year == year))
}

cities_df$glasgow_nc <- 0
cities_df$edinburgh_nc <- 0
cities_df$dublin_nc <- 0
cities_df$london_nc <- 0
cities_df$cambridge_nc <- 0
cities_df$oxford_nc <- 0
cities_df$boston_nc <- 0
cities_df$total_nc <- 0

#cities <- c("Glasgow", "Edinburgh", "Dublin", "London", "Cambridge", "Oxford", "Boston Ma")
for(i in 1:nrow(cities_df)) {
  cat("\r", i)
  year <- i + 1499
  for(x in 1:length(cities)) {
    cities_df[i,x+9] <- length(intersect(which(works_places$publication_place == cities[x]),which(works_places$publication_year == year)))
  }
  cities_df$total_nc[i] <- length(which(works_places$publication_year == year))
}

temp <- data.frame(years = cities_df$years[202:301],
                   Glasgow=cities_df$glasgow[202:301]/cities_df$glasgow_nc[202:301],
                   Edinburgh=cities_df$edinburgh[202:301]/cities_df$edinburgh_nc[202:301],
                   Dublin=cities_df$dublin[202:301]/cities_df$dublin_nc[202:301],
                   London=cities_df$london[202:301]/cities_df$london_nc[202:301],
                   Cambridge=cities_df$cambridge[202:301]/cities_df$cambridge_nc[202:301],
                   Oxford=cities_df$oxford[202:301]/cities_df$oxford_nc[202:301],
                   Boston=cities_df$boston[202:301]/cities_df$boston_nc[202:301])


years <- seq(1705, 1800, by=5)
old_year <- 1700
Glasgow <- c()
Edinburgh <- c()
Dublin <- c()
London <- c()
Cambridge <- c()
Oxford <- c()
Boston <- c()
for(i in 1:20) {
  temp_yeas_loc <- intersect(which(cities_df$years < years[i]+1),which(cities_df$years > old_year))
  Glasgow <- c(Glasgow, sum(cities_df[temp_yeas_loc, 2]) / sum(cities_df[temp_yeas_loc, 10]) * 100)
  Edinburgh <- c(Edinburgh, sum(cities_df[temp_yeas_loc, 3]) / sum(cities_df[temp_yeas_loc, 11]) * 100)
  Dublin <- c(Dublin, sum(cities_df[temp_yeas_loc, 4]) / sum(cities_df[temp_yeas_loc, 12]) * 100)
  London <- c(London, sum(cities_df[temp_yeas_loc, 5]) / sum(cities_df[temp_yeas_loc, 13]) * 100)
  Cambridge <- c(Cambridge, sum(cities_df[temp_yeas_loc, 6]) / sum(cities_df[temp_yeas_loc, 14]) * 100)
  Oxford <- c(Oxford, sum(cities_df[temp_yeas_loc, 7]) / sum(cities_df[temp_yeas_loc, 15]) * 100)
  Boston <- c(Boston, sum(cities_df[temp_yeas_loc, 8]) / sum(cities_df[temp_yeas_loc, 16]) * 100)
  old_year <- years[i] 
}

temp_2 <- data.frame(years=years,
                     Glasgow=Glasgow,
                     Edinburgh=Edinburgh,
                     Dublin=Dublin,
                     London=London,
                     Cambridge=Cambridge,
                     Oxford=Oxford,
                     Boston=Boston)


fig <- ggplot(temp_2, aes(x=years)) +
  geom_smooth(aes(y = Glasgow, colour = "Glasgow")) + 
  geom_smooth(aes(y = Edinburgh, colour="Edinburgh")) +
  geom_smooth(aes(y = Dublin, colour="Dublin")) +
  geom_smooth(aes(y = London, colour="London")) +
  geom_smooth(aes(y = Cambridge, colour="Cambridge")) +
  geom_smooth(aes(y = Oxford, colour="Oxford")) +
  geom_smooth(aes(y = Boston, colour="Boston")) +

  geom_point(aes(y = Glasgow, colour = "Glasgow")) + 
  geom_point(aes(y = Edinburgh, colour="Edinburgh")) +
  geom_point(aes(y = Dublin, colour="Dublin")) +
  geom_point(aes(y = London, colour="London")) +
  geom_point(aes(y = Cambridge, colour="Cambridge")) +
  geom_point(aes(y = Oxford, colour="Oxford")) +
  geom_point(aes(y = Boston, colour="Boston")) +
  theme_comhis(type="discrete") +
  #scale_colour_manual(values = c(gdocs_pal()(3))) +
  scale_linetype_manual(values = c(1, 2)) +
  scale_x_continuous(breaks = seq(1700, 1800, 20)) + 
  labs(y="Canon share (%)", x="Years") +
  #scale_y_continuous(labels = percent) +
  
  theme(legend.title=element_blank())


#scale_color_discrete(breaks=c("Glasgow", "Boston", "Edinburgh", "London", "Dublin", "Oxford", "Cambridge")) +

save_plot_image(fig, plotname = "fig18", outputdir = "../output/figures/",
                size_preset = "custom", file_format = "eps", width=19, height=14)

# 
# plot(cities_df$glasgow[200:300]/cities_df$glasgow_nc[200:300], type = "l", col = "red", xaxt = "n")
# x<-seq(0, 100, 10)
# lables<-x+1700
# axis(1, x, labels=as.character(lables), las=2)
# lines(cities_df$london[200:300]/cities_df$london_nc[200:300], type = "l")
# lines(cities_df$dublin[200:300]/cities_df$dublin_nc[200:300], type = "l", col = "green")
# lines(cities_df$edinburgh[200:300]/cities_df$edinburgh_nc[200:300], type = "l", col = "blue")
# lines(cities_df$cambridge[200:300]/cities_df$cambridge_nc[200:300], type = "l", col = "yellow")
# lines(cities_df$oxford[200:300]/cities_df$oxford_nc[200:300], type = "l", col = "light blue")
# lines(cities_df$boston[200:300]/cities_df$boston_nc[200:300], type = "l", col = "dark green")


# temp_fig <- ggplot(temp, aes(x=years)) +
#   geom_smooth(aes(y = Glasgow, colour = "Glasgow")) +
#   geom_smooth(aes(y = Edinburgh, colour="Edinburgh")) +
#   geom_smooth(aes(y = Dublin, colour="Dublin")) +
#   geom_smooth(aes(y = London, colour="London")) +
#   geom_smooth(aes(y = Cambridge, colour="Cambridge")) +
#   geom_smooth(aes(y = Oxford, colour="Oxford")) +
#   geom_smooth(aes(y = Boston, colour="Boston")) +
# 
#   geom_point(aes(y = Glasgow, colour = "Glasgow")) +
#   geom_point(aes(y = Edinburgh, colour="Edinburgh")) +
#   geom_point(aes(y = Dublin, colour="Dublin")) +
#   geom_point(aes(y = London, colour="London")) +
#   geom_point(aes(y = Cambridge, colour="Cambridge")) +
#   geom_point(aes(y = Oxford, colour="Oxford")) +
#   geom_point(aes(y = Boston, colour="Boston")) +
# 
#   theme_comhis(type="discrete") +
#   #scale_colour_manual(values = c(gdocs_pal()(3))) +
#   scale_linetype_manual(values = c(1, 2)) +
#   scale_x_continuous(breaks = seq(1700, 1800, 20)) +
#   labs(y="Canon share (%)", x="Years") +
#   #scale_y_continuous(labels = percent) +
#   theme(legend.title=element_blank())
# 
# save_plot_image(temp_fig, plotname = "fig18.test", outputdir = "../output/figures/",
#                 size_preset = "custom", file_format = "eps", width=19, height=14)
