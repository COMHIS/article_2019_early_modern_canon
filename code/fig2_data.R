xc2 <- canon %>% filter(is_canon == TRUE)
yo <- ac41 %>% filter(finalWorkField %in% xc2$work_titles) %>%
                filter(!is.na(publication_year)) %>%
      	     	arrange(publication_year) %>%
             	filter(actor_role_author == "True") %>%
             	distinct(curives, .keep_all = TRUE) %>% 
  	     	mutate(short = as.factor(short)) %>% arrange(publication_year) %>% 
  	     	mutate(short = factor(short, levels = unique(short))) 

