d <- ac4 %>%  filter(publication_year >= 1470 & publication_year <= 1800) %>%
              filter(!is.na(publication_year) & !is.na(finalWorkField)) %>%
	      arrange(publication_year, actor_id) %>%
	      rename(work = finalWorkField) %>%
	      rename(year = publication_year) %>%
	      rename(decade = publication_decade) %>%	      
	      rename(actor = actor_id) %>%     	     	      
	      mutate(canon = work %in% canon.works) %>%
	      filter(canon)

d$genre <- canon$simplified_dd_subject[match(d$work, canon$work_titles)]
top.genres <- names(top(d$genre)[1:7])

d2 <- d
d2$genre <- as.character(d2$genre)
d2$genre[which(!d2$genre %in% top.genres)] <- "Other"
d2$genre <- factor(d2$genre, levels = c(top.genres, "Other"))

df <- d2 %>% select(decade, genre, curives) %>%
            filter(!is.na(genre)) %>% 
            unique() %>%
	    group_by(decade, genre) %>%
	    dplyr::summarise(n = n()) %>%
	    dplyr::mutate(f = n/sum(n)) %>%
	    dplyr::select(decade, genre, f, n) 
