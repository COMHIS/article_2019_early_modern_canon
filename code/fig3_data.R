### otetaan tarkasteluun sellaiset workfieldit jotka ovat vähintään jonain vuosikymmenenä ykkösenä
dds <- dd %>% filter(rank == "1") %>%
              distinct(work, .keep_all = TRUE)

gg3$no1 <- dds$decade[match(gg3$finalWorkField, dds$work)]

yo <- gg3 %>%
  filter(!is.na(no1)) %>%
  arrange(publication_year) %>%
  filter(actor_role_author == "True") %>% distinct(curives, .keep_all = TRUE) %>%
  mutate(finalWorkField = as.factor(finalWorkField)) %>% 
  arrange(publication_year) %>%
  mutate(finalWorkField = factor(finalWorkField, levels = unique(finalWorkField))) %>%
  arrange(publication_year) %>%
  filter(!is.na(publication_year))


