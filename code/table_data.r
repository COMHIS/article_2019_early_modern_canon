#Data for tables

'%!in%' <- function(x,y)!('%in%'(x,y))
canon <- read.csv("../data/work/canon.csv", stringsAsFactors = FALSE)
canon <- canon[1:1000,]
author_data <- read.csv("../../estc-author-analysis-data/author_analysis_finished.csv", stringsAsFactors = FALSE)
works_places <- read.csv("../data/work/works_places.csv", stringsAsFactors = FALSE)
pub_location <- read.csv("../../estc-data-unified/estc-cleaned-initial/estc_processed.csv", stringsAsFactors = FALSE)
pub_location <- pub_location[,c(52,78,79)]

################################################################
#Table 1 data - Top 20 works of canon

canon$work_titles[which(canon$is_canon == TRUE)][1:20]
canon$author[which(canon$is_canon == TRUE)][1:20]
canon$total_pubs[which(canon$is_canon == TRUE)][1:20]

################################################################
#Table 2 data - top five works of fiction, poetry, and drama

canon$work_titles[which(canon$simplified_dd_subject == "Fiction")[1:10]]
canon$work_titles[which(canon$simplified_dd_subject == "Poetry")[1:10]]
canon$work_titles[which(canon$simplified_dd_subject == "Drama")[1:10]]

#author_data$title[which(author_data$estc_id %in% works_places$system_control_number[which(works_places$finalWorkField == "xxxx")])]

################################################################
#Table 3 data - authors of most canon, most canon eds, most eds

non_corp_canon <- canon[which(canon$is_corp == FALSE),]

#Canon works
sort(table(non_corp_canon$author), decreasing = TRUE)[1:10]

#Canon eds
ag_canon <- non_corp_canon
ag_canon <- ag_canon[which(ag_canon$is_canon == TRUE),]
ag_canon <- aggregate(ag_canon$total_pubs, by = list(ag_canon$author), FUN = sum)
ag_canon <- ag_canon[order(-ag_canon$x),]
ag_canon[1:10,]

#All eds
non_canon_author_data <- author_data[-c(grep(".1.", author_data$tag)),]
non_canon_author_data <- non_canon_author_data[which(non_canon_author_data$role == "Author"),]
sort(table(non_canon_author_data$unique_name), decreasing = TRUE)[1:10]

################################################################
#Table 4 data - Distribution of subject topics among the works by top authors, 1500 to 1800.

sort(table(canon$simplified_dd_subject[which(canon$author %in% names(sort(table(non_corp_canon$author), decreasing = TRUE)[1:10]))]), decreasing = TRUE)

################################################################
#Table 5 data - Top printing locations in the whole ESTC and in the canon, 1500-1800

#estc
sort(table(pub_location$publication_place), decreasing = TRUE)[1:10]

#canon
canon_titles <- canon$work_titles[which(canon$is_canon == TRUE)]
sort(table(works_places$publication_place[which(works_places$finalWorkField %in% canon_titles)]), decreasing = TRUE)[1:10]

################################################################
#Table 6 data - Canon first, and canon subsequent editions

canon_works <- canon$work_titles[which(canon$is_canon == TRUE)]
canon_places <- works_places[which(works_places$finalWorkField %in% canon_works),]
canon_places <- canon_places[order(canon_places$finalWorkField),]


fe_places <- data.frame(city=unique(works_places$publication_place), total_eds=0)
se_places <- data.frame(city=unique(works_places$publication_place), total_eds=0)

titles <- unique(canon_places$finalWorkField)
for(i in 1:length(titles)) {
  cat(titles[i], "\n")
  locs <- which(canon_places$finalWorkField == titles[i])
  #fe
  fes <- locs[which(canon_places$fe[locs] == TRUE)]
  if (all(canon_places$mfe_sus_multi_city[fes] != TRUE)) {
    fe_places$total_eds[which(fe_places$city == unique(canon_places$publication_place[fes]))] <-
      fe_places$total_eds[which(fe_places$city == unique(canon_places$publication_place[fes]))] + 1
    #locs <- locs[-c(fes)]
    locs <- locs[-c(which(canon_places$publication_place[locs] == unique(canon_places$publication_place[fes])))]
    
  } else {
    next
  }
  #se
  se_place_list <- unique(canon_places$publication_place[locs])
  for(x in 1:length(se_place_list)) {
    se_places$total_eds[which(se_places$city == se_place_list[x])] <-
      se_places$total_eds[which(se_places$city == se_place_list[x])] + 1
  }
}

fe_places <- fe_places[order(-fe_places$total_eds),]
se_places <- se_places[order(-se_places$total_eds),]

fe_places[1:10,]
se_places[1:10,]
