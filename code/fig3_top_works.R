### timeline of top-works

rename <- dplyr::rename
theme_set(theme_bw(20))

d <- gg3 %>% filter(publication_year.y >= 1470 & publication_year.y <= 1800) %>%
  filter(!is.na(publication_year.y) & !is.na(finalWorkField)) %>%
  rename(work = finalWorkField) %>%
  rename(year = publication_year.y) %>%
  rename(decade = publication_decade) %>%	      
  rename(actor = actor_id) %>%
  arrange(year, work) %>%
  mutate(first_year = !duplicated(work)) # First year published

dd <- d %>% select(decade, work, first_year) %>%
  filter(first_year) %>%
  unique() %>%
  select(decade, work) %>%
  left_join(top.works, "work") %>%
  arrange(decade, desc(n)) 

# Add counters
library(data.table)
DT <- data.table(dd)
DT[, rank := seq_len(.N), by = decade]
# DT[, rank := rowid(decade)]
# Top 10 per decade
dd <- as_tibble(DT) %>%
  filter(rank <= 10)

### otetaan tarkasteluun sellaiset workfieldit jotka ovat vähintään jonain vuosikymmenenä ykkösenä

dds <- dd %>% filter(rank == "1")

dds <- dds %>% distinct(work, .keep_all = TRUE)

gg3$no1 <- dds$decade[match(gg3$finalWorkField, dds$work)]

gg6 <- gg3 %>% filter(!is.na(no1))

gg6 <- gg6 %>% arrange(publication_year.x)

gg7 <- gg6 %>% distinct(finalWorkField, .keep_all = TRUE)
dt <- setDT(gg6)
d6 <- dt[, .N, by=.(short)]

xx9 <- gg6 %>% filter(actor_role_author == "True")

xx9 <- xx9 %>% distinct(curives, .keep_all = TRUE)


## grouping
yo <- xx9 %>%
  mutate(finalWorkField = as.factor(finalWorkField)) %>% 
  arrange(publication_year.x) %>%
  mutate(finalWorkField = factor(finalWorkField, levels = unique(finalWorkField)))

yo <- arrange(yo, publication_year.x)

yo <- yo %>% filter(!is.na(publication_year.x))

yo <- as.data.frame(yo)

## print plot
p <- ggplot(data = yo, aes(y = finalWorkField, x = publication_decade)) + 
  geom_count(breaks=seq(1450, 1800, by=25), limits=c(1450, 1800)) +
  theme(axis.text.y = element_text(size = 16)) + 
  theme(legend.position="none") + labs(x = "Decade", y = "Works", title = paste("Timeline of top works"))  + scale_y_discrete(labels =  yo[match(levels(yo$finalWorkField), yo$finalWorkField), "short"]) + 
  grids(linetype = "dashed")

print(p)
