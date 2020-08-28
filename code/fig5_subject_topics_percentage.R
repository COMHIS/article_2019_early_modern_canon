# Load libraries
library(ggplot2)
library(tidyr)
library(dplyr)
library(reshape2)
library(bibliographica)
library(dplyr)
library(data.table)

rename <- dplyr::rename
theme_set(theme_bw(20))

xc1 <- read.csv(file="canon.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

xc2 <- xc1 %>% filter(is_canon == TRUE)

gg3 <- ac41 %>% filter(finalWorkField %in% xc2$work_titles)

gg3$cats <- xc1$simplified_dd_subject[match(gg3$finalWorkField, xc1$work_titles)]

d <- gg3 %>% filter(publication_year.y >= 1470 & publication_year.y <= 1800) %>%
  filter(!is.na(publication_year.y) & !is.na(finalWorkField)) %>%
  rename(work = finalWorkField) %>%
  rename(year = pubyear) %>%
  rename(decade = publication_decade) %>%	      
  rename(actor = actor_id) %>%
  arrange(year, work) %>%
  mutate(first_year = !duplicated(work)) # First year published

top.works <- d %>% select(work, curives) %>%
  unique() %>%
  group_by(work) %>%
  tally() %>%
  arrange(desc(n))

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
DT[, rank := rowid(decade)]

# Top 10 per decade
dd <- as_tibble(DT) %>%
  filter(rank <= 10)

gg6 <- gg3 %>% filter(is_organization == "False")

gg8 <- gg6 %>% filter(finalWorkField %in% dd$work)

gg8$top <- gg8$cats[match(gg8$finalWorkField, dd$work)]

pop <- names(rev(sort(table(gg8$cats))))[1:5]

af <- gg8 %>% group_by(publication_decade, cats) %>%
  arrange(publication_decade) %>%
  summarize(n = n()) %>%
  group_by(publication_decade) %>%
  mutate(f = n/sum(n)) %>%   
  dplyr::filter(cats %in% pop) 

### plot

can8 <- ggplot(af, aes(x = publication_decade, y = f, fill = cats))  + 
  geom_bar(stat = "identity", colour="black", position=position_fill(), width=20) + 
  scale_x_continuous(limits=c(1450, 1800)) +
  labs(x = "Publication year",
       y = "Category percentage",
       title = paste("top-5 categories of canon, works published each decade"))

print(can8)