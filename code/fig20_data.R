df0 <- ac41

# Consider top gatherings only
df <- df0 %>% filter(gatherings %in%  names(top(df0$gatherings)[1:4])) %>%
	      rename(work = finalWorkField) %>%
	      mutate(canon = work %in% canon.works) %>%
	      filter(canon)
df$gatherings <- order_gatherings(df$gatherings)
df$work <- factor(df$work)

# Replace gatherings with Large/Small
#df$gatherings2 <- rep("Other", nrow(df))
#df$gatherings2[df$gatherings %in% c("2fo", "4to")] <- "Large"
#df$gatherings2[df$gatherings %in% c("8vo", "12mo")] <- "Small"
#df$gatherings <- df$gatherings2; df$gatherings2 <- NULL
#df <- df %>% filter(gatherings %in% c("Large", "Small"))
#df$gatherings <- factor(df$gatherings, levels = c("Small", "Large"))
df <- df %>% dplyr::filter(gatherings %in% c("2fo", "4to", "8vo", "12mo"))


df2 <- df %>% dplyr::select(work, curives) %>% unique() 
#top.works <- names(which(top(df2$work) > 30))
top.works <- c("11-short introduction of grammar", "13-aesops fables", "18-paradise lost poem in twelve books")

d <- df %>% filter(work %in% top.works) %>%
            select(publication_decade, work, curives, gatherings) %>%
	    unique()

dt <- setDT(d)
d <- dt[, .N, by=.(gatherings, curives, work)]
d <- data.frame(d) %>% arrange(work, gatherings)

#div <- d %>% filter(!is.na(gatherings)) %>%
#             filter(!is.na(work)) %>%
#             rename(work = work) %>%	     
#             group_by(work) %>%
#             summarize(
#	       diversity = vegan::diversity(N, index = "shannon"),#
#	       richness = length(N),
#	       titlecount = sum(N)
#	     ) %>%
#	     arrange(desc(diversity))

d <- dt[, .N, by=.(publication_decade, gatherings, work)]
d <- data.frame(d) %>%
       arrange(publication_decade, work, gatherings) %>%
       rename(work = work)




