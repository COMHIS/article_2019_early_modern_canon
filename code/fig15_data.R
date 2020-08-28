gg3 <- gg3 %>% distinct(curives, .keep_all = TRUE)

### 1e) Summary; top places of publication excluding London
top <- names(rev(sort(table(gg3$publoc))))[2:9]

af <- gg3 %>% group_by(publication_decade, publoc) %>%
  #filter(publication_decade < 1800) %>%
  arrange(publication_decade) %>%
  summarize(n = n()) %>%
  group_by(publication_decade) %>%
  mutate(f = n/sum(n)) %>%
  dplyr::filter(publoc %in% top)

