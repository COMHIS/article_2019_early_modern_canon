ac41 <- as.data.frame(ac41)

xc1 <- read.csv(file="canon.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

xc2 <- xc1 %>% filter(is_canon == TRUE)

xc1 <- read.csv(file="canon.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

xc2 <- xc1 %>% filter(is_canon == TRUE)

gg3 <- ac41 %>% filter(finalWorkField %in% xc2$work_titles)

gg3$cats <- xc1$simplified_dd_subject[match(gg3$finalWorkField, xc1$work_titles)]

gg3 <- gg3 %>% distinct(curives, .keep_all = TRUE)

### 1e) Summary; top places of publication excluding London

top <- names(rev(sort(table(gg3$publoc))))[2:9]

af <- gg3 %>% group_by(publication_decade, publoc) %>%
  arrange(publication_decade) %>%
  summarize(n = n()) %>%
  group_by(publication_decade) %>%
  mutate(f = n/sum(n)) %>%
  dplyr::filter(publoc %in% top)

### plot

can8 <- ggplot(af, aes(x = publication_decade, y = f, fill = publoc))  + 
  geom_bar(stat = "identity", colour="black", position=position_fill(), width=20) + 
  scale_x_continuous(limits=c(1450, 1800)) +
  labs(x = "Publication year",
       y = "Place of publication percentage",
       title = paste("Summary of places (London excluded)"))

print(can8)

