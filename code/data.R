# Define file paths and libraries
source("init.R")

summarize <- dplyr::summarize

# Canon
canon <- read.csv(canon_csv)

##unified actor analysis

ac1 <- read.csv(file = actors_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE)

### adding actor links

ac2 <- read.csv(file=actorlinks_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE)

ac3 <- merge(ac1, ac2, by.x="actor_id", by.y="actor_id", all = TRUE)

### Ali's new data

ed1 <- read.csv(workdata_csv, sep = ',', header = TRUE)

ac4 <- merge(ac3, ed1, by.x="curives", by.y="system_control_number", all = TRUE)

### add publication year info

cc2 <- read.csv(file=pubyears_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE)
ac4 <- merge(ac4, cc2, by.x="curives", by.y="system_control_number", all = TRUE)
ac4 <- ac4[-c(1140940:1140947), ]  # Explanatin TBA
ac4 <- ac4 %>% filter(!is.na(curives))

### merge old estc data 

sf <- read.csv(file=estc_titles_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE)

sf <- sf %>% filter(!is.na(system_control_number))

### pick only needed categories before merging

myvars <- as.vector(c("system_control_number", "language.English", "language.French", "language.Latin", "language", 
                      "title", "pagecount", "publisher",
                      "latitude", "longitude", "document_type", "publication_decade", "gatherings", "paper"))

sf1 <- sf[myvars]

#### merge

ac4 <- merge(ac4, sf1, by.x="curives", by.y="system_control_number", all = TRUE)
ac4 <- ac4[-c(1:7), ] 
ac4 <- ac4[-c(1142105:1142112), ]  # Explanation TBA
ac4 <- ac4 %>% filter(!is.na(curives))
ac4$short <- sapply(str_split(ac4$finalWorkField, " "), function (xi) {paste(xi[1:min(length(xi), 5)], collapse = " ")})
ac4$short <- gsub("[0-9.]", "", ac4$short)
ac4$short <- gsub("-", "", ac4$short)
ac4 <- ac4 %>% rename(publication_year = pubyear)
ac4$publication_year.x <- NULL
ac4$publication_year.y <- NULL
ac4$publication_year <- as.numeric(ac4$publication_year)

## Add categories
vv <- read.csv(file=subject_topic_data_csv, sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))
vv2 <- vv %>% filter(!is.na(st_final_s))
vv3 <- ac4 %>% filter(work_id %in% vv2$work_id)
vv3$cats <- vv$st_final_s[match(vv3$work_id, vv$work_id)]
ac4$cats <- vv3$cats[match(ac4$work_id,  vv3$work_id)]
ac4 <- as.data.frame(ac4)

# Pick subset that has only real work ids
ac41 <- ac4 %>% filter(!is.na(work_id)) %>%
                filter(!work_id == "no_work_id") %>%
		as.data.frame()
# Simplify subject field
ac41$simplified_dd_subject <- canon$simplified_dd_subject[match(ac41$finalWorkField, canon$work_titles)]

# --------------------------------------------------

# Create gg3
xc2 <- canon %>% filter(is_canon == TRUE)
gg3 <- ac41 %>% filter(finalWorkField %in% xc2$work_titles)
gg3$cats <- canon$simplified_dd_subject[match(gg3$finalWorkField, canon$work_titles)]

d <- gg3 %>% filter(publication_year >= 1470 & publication_year <= 1800) %>%
  filter(!is.na(publication_year) & !is.na(finalWorkField)) %>%
  rename(work = finalWorkField) %>%
  rename(year = publication_year) %>%
  rename(decade = publication_decade) %>%	      
  rename(actor = actor_id) %>%
  arrange(year, work) %>%
  mutate(first_year = !duplicated(work)) # First year published

top.works <- d %>% select(work, curives) %>%
  unique() %>%
  group_by(work) %>%
  tally() %>%
  arrange(desc(n))

dd <- d %>%
  filter(first_year) %>%
  select(decade, work, first_year) %>%  
  unique() %>%
  select(decade, work) %>%
  left_join(top.works, "work") %>%
  arrange(decade, desc(n)) 

# Add counters
library(data.table)
DT <- data.table(dd)
DT[, rank := seq_len(.N), by = decade]

# Top 10 per decade
dd <- as_tibble(DT)

# Canon work definition
canon.works <- (canon %>% filter(is_canon == TRUE))$work_titles

# Store the constructed data frames
saveRDS(ac4, file = "ac4.Rds")
saveRDS(ac41, file = "ac41.Rds")
saveRDS(gg3, file = "gg3.Rds")
saveRDS(dd, file = "dd.Rds")
saveRDS(canon.works, file = "canon.works.Rds")



