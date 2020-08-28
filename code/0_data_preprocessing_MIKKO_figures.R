library(ggplot2)
library(dplyr)
library(stringr)
library(stringi)
library(devtools)
library(DataCombine)
library(qdap)
library(reshape2)
library(zoo)
library(tidyr)
library(ggpmisc)
library(ggspectra)
library(tidyverse)
library(bibliographica)
library(RColorBrewer)
library(wesanderson)
library(cowplot)
library(ggpubr)
library(hexbin)
library(lattice)
library(plyr)
library(reshape2)
library(XML)
library(netdiffuseR)
library("Matrix")
library(reshape)
library("igraph")
library("rgexf")
library(data.table)
library(tidyverse)
library(rmarkdown)
library(gghighlight)
library(ggfortify)
library(viridisLite)
library('rwantshue')
library(ggthemes) 
library(bibliographica)
library(knitr)
Sys.setlocale(locale="UTF-8") 

summarize <- dplyr::summarize

##unified actor analysis

ac1 <- read.csv(file="unified_actors.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE)

### adding actor links

ac2 <- read.csv(file="unified_actorlinks_enriched.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE)

ac3 <- merge(ac1, ac2, by.x="actor_id", by.y="actor_id", all = TRUE)

### Ali's new data

ed1 <- read.csv("estc_works_roles.csv", sep = ',', header = TRUE)

ac4 <- merge(ac3, ed1, by.x="curives", by.y="system_control_number", all = TRUE)

### add publication year info

cc2 <- read.csv(file="publicationyears.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE)

ac4 <- merge(ac4, cc2, by.x="curives", by.y="system_control_number", all = TRUE)

ac4 <- ac4[-c(1140940:1140947), ] 

ac4 <- ac4 %>% filter(!is.na(curives))

### merge old estc data 

sf <- read.csv(file="estc_processed.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE)

sf <- sf %>% filter(!is.na(system_control_number))

### pick only needed categories before merging

myvars <- as.vector(c("system_control_number", "language.English", "language.French", "language.Latin", "language", 
                      "title", "pagecount", "publisher",
                      "latitude", "longitude", "document_type", "publication_decade", "gatherings", "paper"))

sf1 = sf[myvars]

#### merge

ac4 <- merge(ac4, sf1, by.x="curives", by.y="system_control_number", all = TRUE)

ac4 <- ac4[-c(1:7), ] 

ac4 <- ac4[-c(1142105:1142112), ] 

ac4 <- ac4 %>% filter(!is.na(curives))

ac4$short <- sapply(str_split(ac4$finalWorkField, " "), function (xi) {paste(xi[1:min(length(xi), 5)], collapse = " ")})

ac4$short <- gsub("[0-9.]", "", ac4$short)

ac4$short <- gsub("-", "", ac4$short)

ac41 <- ac4 %>% filter(!is.na(work_id))

ac41 <- ac41[- grep("no_work_id", ac41$work_id),]

### adding categories

vv <- read.csv(file="work_subject_topics_combined.csv", sep = ',',header = TRUE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

vv2 <- vv %>% filter(!is.na(st_final_s))

vv3 <- ac41 %>% filter(work_id %in% vv2$work_id)

vv3$cats <- vv$st_final_s[match(vv3$work_id, vv$work_id)]

ac4$cats <- vv3$cats[match(ac4$work_id, vv3$work_id)]

ac41 <- ac4 %>% filter(!is.na(work_id))

ac41 <- ac41[- grep("no_work_id", ac41$work_id),]
