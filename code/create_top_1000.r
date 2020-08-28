#Create canon CSV for public
library(dplyr)

canon <- read.csv("../data/work/canon.csv", stringsAsFactors = FALSE)
canon <- canon[1:1000,]
canon <- canon[,-c(2:3,5:8,11,12,14:17,19:21)]
#canon <- canon[,-c(5:8,11,12,14:17,19:21)]

canon <- canon %>%
           select(work_titles, total_pubs, title, author, simplified_dd_subject, is_canon) %>%
	   mutate(work_titles = gsub("^[0-9]+.", "", work_titles)) %>%
	   mutate(is_canon = gsub("TRUE", "X", is_canon)) %>%
	   mutate(is_canon = gsub("FALSE", "", is_canon)) %>%
	   arrange(author) %>% 
	   rename(
	     Work = work_titles,
	     Editions = total_pubs,
	     Title = title,
	     Author = author,
	     "Subject topic" = simplified_dd_subject,
	     "Key work" = is_canon
		)

# clean work title
write.table(canon, file = "../data/final/canon_1000_for_public.csv", row.names = FALSE, quote = FALSE, sep = "\t")


library(knitr)
library(rmarkdown)
render("canon.Rmd", output_format = "html_document")

