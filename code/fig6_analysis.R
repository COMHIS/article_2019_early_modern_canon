n <- Inf

df <- ac4 %>% filter(publication_year >= 1470 & publication_year <= 1800) %>%
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

df <- df %>% summarize(year_death = unique(year_death),
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


# median number of years to the first publication after death is 31
d <- df0 %>% dplyr::filter(first_year_after_death == TRUE) %>% arrange(actor_id) %>% select(actor_id, years_after_death) %>% unique()
print("Median time (in years) to first postmortem publication")
print(median(d$years_after_death))

# for 17% of the 2,514 authors who were included in this analysis
# the first posthumous publication appears over 100 years after death
print("Number of unique authors")
print(length(unique(d$actor_id)))

print("First Posthumuous publication after 100 years: number and percentage of authors")

print(paste("N=", nrow(subset(d, years_after_death > 100))))
print(paste("f=", 100 * nrow(subset(d, years_after_death > 100))/nrow(d)))







