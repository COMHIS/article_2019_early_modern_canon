### canon vs ESTC subsetted to one curives
bc4 <- ac4 %>% arrange(publication_year) %>%
               distinct(curives, .keep_all = TRUE) %>%
	       arrange(publication_year)

fc4 <- bc4 %>% distinct(finalWorkField, .keep_all = TRUE)

#### workfield stuff
gg3 <- gg3 %>% distinct(curives, .keep_all = TRUE)
myvars <- as.vector(c("publication_year", "curives"))
a1 = bc4[myvars]
c1 = fc4[myvars]
d1 = gg3[myvars]

#a1$var <- "ESTC/483k"
#c1$var <- "Unique_works/200k"
#d1$var <- "Canon/34k"

a1$var <- "ESTC"
c1$var <- "Unique works"
d1$var <- "Canon"

g1 <- rbind(a1, c1, d1)
g1$data <- as.character(g1$var)
g1$curives[is.na(g1$curives)] <- 0
g1 <- g1 %>% filter(publication_year > 1449) %>%
             filter(publication_year < 1800)

