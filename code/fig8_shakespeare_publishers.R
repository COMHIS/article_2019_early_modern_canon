qw <- subset(ac4, actor_role_author == "True")

qw <- qw %>% group_by(actor_id, name_unified, year_birth) %>%
  summarize(n = n())

dfa <- arrange(dfa, publication_year.x)

### making shorter labels

ac4$short <- sapply(str_split(ac4$finalWorkField, " "), function (xi) {paste(xi[1:min(length(xi), 5)], collapse = " ")})

### making the Shakespeare workfield dataset

qw1 <-  ac41 %>% subset(actor_id == "96994048") # subset to Shakespeare

qw1 <- qw1 %>% filter(!is.na(finalWorkField))

ws <- ac41 %>% filter(finalWorkField %in% qw1$finalWorkField) # take all WF 

### making a full list of top actors ( all publishers and printers)

ws1 <- subset(ws, actor_role_publisher == "True" | 
                actor_role_printer == "True" | actor_role_bookseller == "True")

ws2 <- ws1 %>% group_by(actor_id) %>%
  summarize(n = n())

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

ws1 <- arrange(ws1, publication_year.x)

## grouping
ws1 <- ws1 %>% filter(finalWorkField %in% names(top)) %>% filter(!is.na(finalWorkField)) %>%
  mutate(finalWorkField = as.factor(finalWorkField)) %>% 
  arrange(publication_decade) %>%
  mutate(finalWorkField = factor(finalWorkField, levels = unique(finalWorkField)))

## print plot
rob <- ggplot(data = ws1, aes(y = finalWorkField, x = publication_decade, colour = big_pubs)) +
  geom_count() +
  theme(axis.text.y = element_text(size = 12)) +
  labs(x = "Printing and publishing Shakespeare", y = "works",
       title = paste("Shakespeare")) + 
  scale_y_discrete(labels = ws1[match(levels(ws1$finalWorkField), ws1$finalWorkField), "short"]) + 
  grids(linetype = "dashed") 

print(rob)
