ac41 <- as.data.frame(ac41)

ac42 <- ac41 %>% distinct(curives, .keep_all = TRUE)

xc1 <- read.csv(file="canon.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

xc2 <- xc1 %>% filter(is_canon == TRUE)

gg3 <- ac41 %>% filter(finalWorkField %in% xc2$work_titles)

gg3$cats <- xc1$Simple_category[match(gg3$finalWorkField, xc1$work_titles)]

ee <- gg3 %>% mutate(any_author_role = actor_role_author == "True" | 
                       actor_role_attributed_name == "True")  

ee <- ee %>% filter(any_author_role == TRUE)

ee <- subset(ee, is_organization == "False")

dnc3 <- subset(ee, actor_gender %in% c("female")) 

dnc3 <- arrange(dnc3, publication_year.y)

dnc3 <- dnc3 %>% distinct(curives, .keep_all = TRUE)

yy72 <- dnc3 %>% group_by(publication_decade) %>%
  arrange(publication_decade) %>%
  summarize(n = n()) %>%
  group_by(publication_decade)

yy72$n <- unlist(yy72$n)

can8 <- ggplot(yy72, aes(x = publication_decade, y = n))  + 
  geom_bar(stat = "identity") + 
  scale_x_continuous(limits=c(1630, 1800)) +
  labs(x = "decade",
       y = "count",
       title = paste("female publications in canon"))

print(can8)
