anc2 <- gg3 %>% distinct(curives, .keep_all = TRUE) %>%
              ### published after death stuff
              mutate(any_author_role = actor_role_author == "True" | 
                        actor_role_attributed_name == "True") %>%
	      filter(any_author_role == TRUE) %>%
	      filter(is_organization == "False")

################################
#HACK TO CORRECT DODSLEY NAME
anc2$name_unified <- as.character(anc2$name_unified)
anc2$name_unified[grep("DODSLEY, Robert", anc2$name_unified)] <- "Dodsley, Robert, 1704-1764"
anc2$name_unified <- as.factor(anc2$name_unified)
################################

top <- names(rev(sort(table(anc2$name_unified))))[1:30]

df <- anc2 %>% mutate(mygreatfactor = publication_year > year_death)  %>% 
               filter(!is.na(mygreatfactor)) %>%
	       filter(name_unified %in% top) %>% 
	       arrange(year_death) %>%
	       mutate(name_unified = gsub("\\.$", "", name_unified)) %>%
  	       mutate(name_unified = factor(name_unified, levels = unique(name_unified)))
