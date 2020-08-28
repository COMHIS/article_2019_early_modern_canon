ac41 <- as.data.frame(ac41)

ac42 <- ac41 %>% distinct(curives, .keep_all = TRUE)

xc1 <- read.csv(file="canon.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

xc2 <- xc1 %>% filter(is_canon == TRUE)

gg3 <- ac41 %>% filter(finalWorkField %in% xc2$work_titles)

yo <- gg3 %>% filter(!is.na(publication_year.x))

yo <- yo %>% arrange(publication_year.x)

yo <- yo %>% filter(actor_role_author == "True")

yo <- yo %>% distinct(curives, .keep_all = TRUE)

yo <- as.data.frame(yo)

####

yo <- yo %>% 
  mutate(short = as.factor(short)) %>% arrange(publication_year.x) %>% 
  mutate(short = factor(short, levels = unique(short))) 

## print plot
p <- ggplot(data = yo, aes(y = short, x = publication_year.x)) + 
  geom_count() +
  theme(axis.text.y = element_text(size = 4)) + 
  theme(legend.position="none") + labs(x = "Decade", y = "Works", title = paste("Timeline of top works"))  + 
  grids(linetype = "dashed") 

print(p)
