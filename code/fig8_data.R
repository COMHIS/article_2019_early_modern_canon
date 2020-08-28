### making the Shakespeare workfield dataset
qw1 <-  ac41 %>% filter(actor_id == "96994048") %>%  # Shakespeare subset
                 filter(!is.na(finalWorkField))

### making a full list of top actors ( all publishers and printers
ws1 <- ac41 %>% filter(finalWorkField %in% qw1$finalWorkField) %>% # take all WF 
                filter(actor_role_publisher == "True" | 
                       actor_role_printer == "True" |
		       actor_role_bookseller == "True")

############## creating the extra column for top names one by one
pp1 <- ws1 %>% subset(actor_id == "51741707")
pp2 <- ws1 %>% subset(actor_id == "330654")
pp4 <- ws1 %>% subset(actor_id == "121291376")
pp5 <- ws1 %>% subset(actor_id == "http://bbti.bodleian.ox.ac.uk/details/?traderid=109575&printer_friendly=true")
pp6 <- ws1 %>% subset(actor_id == "12361047")
pp7 <- ws1 %>% subset(actor_id == "66386600")
pp8 <- ws1 %>% subset(actor_id == "32051321")
pp9 <- ws1 %>% subset(actor_id == "http://bbti.bodleian.ox.ac.uk/details/?traderid=22793&printer_friendly=true")
pp10 <- ws1 %>% subset(actor_id == "151730662")
pp11 <- ws1 %>% subset(actor_id == "40811864")
pp12 <- ws1 %>% subset(actor_id == "http://bbti.bodleian.ox.ac.uk/details/?traderid=30548&printer_friendly=true")
pp13 <- ws1 %>% subset(actor_id == "76405539")
pp14 <- ws1 %>% subset(actor_id == "http://bbti.bodleian.ox.ac.uk/details/?traderid=60524&printer_friendly=true")
pp15 <- ws1 %>% subset(actor_id == "90694831")

pp1$var <- "Longman"
pp2$var <- "Rivington"
pp4$var <- "e"
pp5$var <- "f"
pp6$var <- "g"
pp7$var <- "h"
pp8$var <- "i"
pp9$var <- "j"
pp10$var <- "k"
pp11$var <- "l"
pp12$var <- "m"
pp13$var <- "n"
pp14$var <- "o"
pp15$var <- "p"

myvars <- as.vector(c("name_unified", "curives"))
a1 = pp1[myvars]
b1 = pp2[myvars]
c1 = pp4[myvars]
d1 = pp5[myvars]
e1 = pp6[myvars]
f1 = pp7[myvars]
g1 = pp8[myvars]
h1 = pp9[myvars]
i1 = pp10[myvars]
j1 = pp11[myvars]
k1 = pp12[myvars]
l1 = pp13[myvars]
m1 = pp14[myvars]
n1 = pp15[myvars]

g1 <- rbind(a1, b1, c1, d1, e1, f1, g1, h1, i1, j1, k1, l1, m1, n1)
ws1$big_pubs <- g1$name_unified[match(ws1$curives, g1$curives)]

### calculating
top <- rev(rev(sort(table(ws1$finalWorkField)))[1:20])

## grouping
ws10 <- ws1

ws1 <- ws10 %>% arrange(publication_year) %>%
  select(publication_decade, finalWorkField, short, big_pubs, curives) %>%
  filter(finalWorkField %in% names(top)) %>%
  filter(!is.na(finalWorkField)) %>%
  unique() %>%
  mutate(finalWorkField = as.factor(finalWorkField)) %>% 
  arrange(publication_decade) %>%
  mutate(finalWorkField = factor(finalWorkField, levels = unique(finalWorkField))) %>%
  mutate(big_pubs = replace(big_pubs, which(is.na(big_pubs)), "Other/Unknown")) %>%
  group_by(publication_decade, finalWorkField, big_pubs, short) %>%
  dplyr::summarise(n = n()) %>%
  select(publication_decade, finalWorkField, big_pubs, short, n) %>%
  group_by(publication_decade, finalWorkField, short) %>%
  dplyr::mutate(f = n/sum(n)) %>%
  arrange(desc(f)) %>%
  filter(row_number() == 1) %>%
  arrange(publication_decade) %>%
  mutate(big_pubs = factor(big_pubs)) %>%
  arrange(publication_decade) %>%
  ungroup() %>%
  mutate(finalWorkField = factor(finalWorkField, levels = unique(finalWorkField))) %>%
  mutate(short = factor(short, levels = unique(short))) %>%
  mutate(big_pubs = factor(big_pubs, levels = c(setdiff(sort(unique(big_pubs)), "Other/Unknown"), "Other/Unknown")))




