ac41 <- as.data.frame(ac41)

xc1 <- read.csv(file="canon.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

xc2 <- xc1 %>% filter(is_canon == TRUE)

gg3 <- ac41 %>% filter(finalWorkField %in% xc2$work_titles)

gg3$cats <- xc1$simplified_dd_subject[match(gg3$finalWorkField, xc1$work_titles)]

gg3 <- gg3 %>% distinct(curives, .keep_all = TRUE)

### published after death stuff

zz <-  gg3 %>% mutate(any_author_role = actor_role_author == "True" | 
                        actor_role_attributed_name == "True")  

zz <- zz %>% filter(any_author_role == TRUE)

anc2 <- subset(zz, is_organization == "False")

anc22 <- anc2 %>% distinct(actor_id, .keep_all = TRUE)

### dealing with years

ss1 <- anc2 %>% filter(!is.na(year_birth))

tit2 <- ss1 %>% filter(!is.na(year_death))

### startYear question

tit2$year_birth[tit2$year_birth==0] <- NA

tit2$year_death[tit2$year_death==0] <- NA

### dealing with years

tit2 <- tit2 %>% filter(!is.na(year_birth))

hh1 <- tit2 %>% filter(!is.na(year_death))

### author at least 30 years old when dead (getting rid of active years)

hh1$age <- hh1$year_death - hh1$year_birth

hh1 <- hh1 %>% filter(age > 29)

### all authors

hh1 <- hh1 %>% filter(year_birth > -10450)
hh1 <- hh1 %>% filter(year_birth < 1801)

### analysis

top <- names(rev(sort(table(anc2$name_unified))))[1:30]

dfa <- anc2

dfa <- arrange(dfa, year_death)

dfa %>% mutate(mygreatfactor = publication_year.x > year_death)  %>% 
  filter(!is.na(mygreatfactor)) %>% filter(name_unified %in% top) %>% 
  mutate(name_unified = as.factor(name_unified)) %>% arrange(year_death) %>% 
  mutate(name_unified = factor(name_unified, levels = unique(name_unified))) %>% 
  ggplot(aes(x = publication_year.x, y = name_unified, color = name_unified)) + 
  geom_count(aes(color = mygreatfactor)) + labs(x = "Year", y = "authors", 
                                                title = "Post-Mortem Publications") + 
  guides(color = guide_legend(title = "published after death"))

