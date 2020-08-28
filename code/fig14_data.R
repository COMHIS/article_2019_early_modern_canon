yy72 <- gg3 %>% mutate(any_author_role = actor_role_author == "True" | 
                       actor_role_attributed_name == "True") %>%
	      filter(any_author_role == TRUE) %>%
	      filter(is_organization == "False") %>%
	      filter(actor_gender %in% c("female")) %>%
	      arrange(publication_year) %>%
	      distinct(curives, .keep_all = TRUE) %>%
	      group_by(publication_decade) %>%
  	      arrange(publication_decade) %>%
  	      summarize(n = n()) %>%
  	      group_by(publication_decade)

yy72$n <- unlist(yy72$n)

