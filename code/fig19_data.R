# Data for Figure 19
# Gatherings for each genre per decade
               # Focus on canon 
df <- ac41 %>% filter(finalWorkField %in% canon$work_titles) %>%
               # All distinct works in the canon (Curives)
               distinct(finalWorkField, curives, .keep_all = TRUE) %>%
	       # Remove invalid/unknown gatherings
               filter(!is.na(gatherings) & !gatherings == "") %>%
	       # SOrt the gatherings by size
               mutate(gatherings = order_gatherings(compress_field(gatherings, topn = 4, rest = "Other"))) %>%
	       # Group the entries for plotting
               dplyr::group_by(publication_decade, simplified_dd_subject, gatherings) %>%
	       # Count sample size in each group
               dplyr::summarise(n = n()) %>%
	       # Regroup again
	       dplyr::group_by(publication_decade, simplified_dd_subject) %>%
	       # Count proportion of gatherings per group (decade + genre)
	       dplyr::mutate(f = n/sum(n))

