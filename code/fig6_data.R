n <- 50

dfx <- ac4 %>% filter(publication_year >= 1470 & publication_year <= 1800) %>%
              filter(!is.na(publication_year) & !is.na(year_birth) & !is.na(year_death) & !is.na(actor_role_author)) %>%
	      filter(actor_role_author == "True") %>%
	      filter(year_birth >= 1450 &
	             year_death >= 1470 &
		     year_death <= 1800) %>%
	      select(publication_year, actor_id,
	             year_birth, year_death,
		     finalWorkField, curives) %>%
	      dplyr::rename(work = finalWorkField) %>% 
	      unique() %>%
	      group_by(actor_id, work) 

df <- dfx %>% summarize(year_death = unique(year_death),
	                first_year_after_death = min((publication_year - unique(year_death))[which(publication_year > unique(year_death))]),
			years_after_death = max(publication_year) - unique(year_death))

print("Remove erroneous years")
df$first_year_after_death[df$years_after_death <= 0] <- NA
df$decade_death <- decade(df$year_death)
df$first_year_after_death[is.na(df$first_year_after_death)] <- -1

df0 <- df %>% mutate(postmortem = first_year_after_death > 0)

df <- df0 %>% group_by(decade_death) %>%
              summarize(f.postmortem.nyears = mean(first_year_after_death > 0 &
	                                           first_year_after_death <= n,
						   na.rm = TRUE))



