df0 <- ac41

# Consider top gatherings only
df <- df0 %>% filter(gatherings %in%  names(top(df0$gatherings)[1:4])) %>%
	      rename(work = finalWorkField) %>%
	      mutate(canon = work %in% canon.works) %>%
	      filter(canon) %>%
	      filter(publication_decade < 1800) 	      
	      
df$gatherings <- order_gatherings(df$gatherings)
df$work <- factor(df$work)

d <- df %>% filter(gatherings %in% c("2fo", "4to", "8vo", "12mo")) %>%
             select(publication_decade, curives, gatherings, paper) %>%
	     unique()

dt <- setDT(d)
#d <- dt[, .N, by=.(publication_decade, gatherings)]
d <- d %>% group_by(publication_decade, gatherings) %>%
           summarize(paper = sum(paper, na.rm = TRUE))

d <- data.frame(d) %>%
       arrange(publication_decade, gatherings) 




