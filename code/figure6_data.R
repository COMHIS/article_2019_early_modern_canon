rename <- dplyr::rename

d <- ac4 %>%  filter(publication_year >= 1470 & publication_year <= 1800) %>%
              filter(!is.na(publication_year) & !is.na(year_birth) & !is.na(year_death) & !is.na(actor_role_author)) %>%
	      filter(actor_role_author == "True") %>%
	      filter(year_birth >= 1450 & year_death >= 1470 & year_death <= 1800) %>%
	      select(publication_year, actor_id, year_birth, year_death, finalWorkField, curives) %>%
	      dplyr::rename(work = finalWorkField) %>% 
	      unique() %>%
	      group_by(actor_id, work) %>%
	      summarize(year_death = unique(year_death),
	                first_year_after_death = min((publication_year - unique(year_death))[which(publication_year > unique(year_death))]),
			years_after_death = max(publication_year) - unique(year_death)) %>%
	      mutate(postmortem = first_year_after_death > 0)
d$first_year_after_death[d$years_after_death <= 0] <- NA

dd <- d %>% group_by(year_death) %>%
            summarize(f = mean(years_after_death > 0, na.rm = TRUE))

n <- 50
dd <- d
dd$decade_death <- decade(dd$year_death)
dd$first_year_after_death[is.na(dd$first_year_after_death)] <- -1
dd <- dd %>% group_by(decade_death) %>%
            summarize(f.postmortem.nyears = mean(first_year_after_death > 0 & first_year_after_death <= n, na.rm = TRUE))

