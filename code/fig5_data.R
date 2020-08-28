dd <- dd %>% filter(rank <= 10)
gg8 <- gg3 %>% filter(is_organization == "False") %>%
               filter(finalWorkField %in% dd$work)
gg8$top <- gg8$cats[match(gg8$finalWorkField, dd$work)]
pop <- names(rev(sort(table(gg8$cats))))[1:5]

af <- gg8 %>% group_by(publication_decade, cats) %>%
  arrange(publication_decade) %>%
  summarize(n = n()) %>%
  group_by(publication_decade) %>%
  mutate(f = n/sum(n)) %>%   
  dplyr::filter(cats %in% pop) 

