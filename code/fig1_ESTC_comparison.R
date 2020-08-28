### canon vs ESTC subsetted to one curives

ac4 <- arrange(ac4, publication_year.y)

bc4 <- ac4 %>% distinct(curives, .keep_all = TRUE)

bc4 <- arrange(bc4, publication_year.y)

fc4 <- bc4 %>% distinct(finalWorkField, .keep_all = TRUE)

#### workfield stuff

ac41 <- as.data.frame(ac41)

ac42 <- ac41 %>% distinct(curives, .keep_all = TRUE)

xc1 <- read.csv(file="canon.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

xc2 <- xc1 %>% filter(is_canon == TRUE)

gg3 <- ac41 %>% filter(finalWorkField %in% xc2$work_titles)

gg3$cats <- xc1$Simple_category[match(gg3$finalWorkField, xc1$work_titles)]

gg3 <- gg3 %>% distinct(curives, .keep_all = TRUE)

#######

myvars <- as.vector(c("publication_decade", "curives"))
a1 = bc4[myvars]
c1 = fc4[myvars]
d1 = gg3[myvars]


a1$var <- "ESTC/483k"
c1$var <- "Unique_works/200k"
d1$var <- "Canon/34k"

g1 <- rbind(a1, c1, d1)

g1$data <- as.character(g1$var)

g1$curives[is.na(g1$curives)] <- 0

g1 <- g1 %>% filter(publication_decade > 1449)
g1 <- g1 %>% filter(publication_decade < 1800)

### plot

can2 <- ggplot(data=g1, aes(publication_decade, fill = data)) + 
  geom_bar(position = 'dodge', stat='count', colour="black", width = 20) +
  scale_x_continuous(limits=c(1500, 1800), 
                     breaks = c(1500, 1550, 1600, 1650, 1700, 1714, 1750, 1774, 1800)) +
  labs(x = "Publication year",
       y = "Title count",
       title = paste("ESTC vs. Unique_works (author known) vs. Canon")) + 
  scale_fill_discrete(breaks=c("ESTC/483k", "One_edition_only/200k", "Canon/34k")) + grids(linetype = "dashed") + 
  scale_x_continuous(breaks=seq(1500, 1800, by=20), limits=c(1500, 1800)) + 
  theme(axis.text.x=element_text(size=15, angle=90,hjust=0.95,vjust=0.2)) + theme_fivethirtyeight() + 
  scale_fill_fivethirtyeight(breaks=c("ESTC/483k", "Unique_works/200k", "Canon/34k"))


print(can2)

