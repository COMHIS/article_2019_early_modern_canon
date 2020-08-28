#Figure 16. Movement of canon editions from original print location.

#This script does not output a visualization, only the data which can then be used with other GIS software

#Load data and create works_places CSV

'%!in%' <- function(x,y)!('%in%'(x,y))
library(igraph)

#SNA functions
source("../code/sna_functions.r")

#works
works <- read.csv("../data/raw/estc_works_roles.csv", stringsAsFactors = FALSE)

#canon
canon <- read.csv("../data/work/canon.csv", stringsAsFactors = FALSE)

#pub place
pub_location <- read.csv("../data/raw/estc_processed.csv", stringsAsFactors = FALSE)
pub_location <- pub_location[,c(52,78,79)]


# Create works_places DF or load it if it exists
if (file.exists("../data/work/works_places.csv")) {
  works_places <- read.csv("../data/work/works_places.csv", stringsAsFactors = FALSE)
  cat("\n", "Publication place and movement data already created. Loading data.")
} else {
  cat("\n", "Creating publication place and movement dataset.")
  works_places <- merge(works, pub_location)
  works_places <- works_places[,-2]
  
  #mark first(ish) and subsequent editions
  works_places$fe <- NA
  works_places$me <- NA
  works_places$mfe <- NA
  
  works_places$me[which(works_places$finalWorkField %in% names(which(table(works_places$finalWorkField) == 1)))] <- FALSE
  works_places$me[which(is.na(works_places$me))] <- TRUE
  names <- unique(works_places$finalWorkField[which(works_places$me == TRUE)])
  
  for(i in 1:length(names)) {
    cat("\r", i, "of", length(names))
    ids <- which(works_places$finalWorkField == names[i])
    min_year <- works_places$publication_year[ids]
    min_year <- min_year[which.min(min_year)]
    min_ids <- ids[which(works_places$publication_year[ids] == min_year)]
    if(length(min_ids) > 1) {
      works_places$mfe[ids] <- TRUE
    }
    works_places$fe[min_ids] <- TRUE
  }
  works_places$mfe[which(is.na(works_places$mfe))] <- FALSE
  works_places$fe[which(is.na(works_places$fe))] <- FALSE
  
  #mfe in different places
  works_places$mfe_sus_multi_city <- FALSE
  mfe_works <- unique(works_places$finalWorkField[intersect(which(works_places$fe == TRUE), which(works_places$mfe == TRUE))])
  for(i in 1:length(mfe_works)) {
    cat("\r", i, "in", length(mfe_works))
    temp_ids <- which(works_places$finalWorkField == mfe_works[i])
    temp_ids <- temp_ids[which(works_places$fe[temp_ids] == TRUE)]
    temp_places <- unique(works_places$publication_place[temp_ids])
    if(length(temp_places) > 1) {
      works_places$mfe_sus_multi_city[temp_ids] <- TRUE
    }
  }
  
  #subsequent editions which are not from that city
  options(warn=2)
  works_places$orig_place <- NA
  works_places$is_orig_place <- FALSE
  me_works <- unique(works_places$finalWorkField[which(works_places$me == TRUE)])
  for (i in 1:length(me_works)) {
    cat("\r", i, "in", length(mfe_works))
    temp_work_ids <- which(works_places$finalWorkField == me_works[i])
    if(any(works_places$mfe_sus_multi_city[temp_work_ids] == TRUE)) {
      works_places$orig_place[temp_work_ids] <- "Unknown"
    } else {
      works_places$orig_place[temp_work_ids] <- unique(works_places$publication_place[temp_work_ids[which(works_places$fe[temp_work_ids] == TRUE)]])
      works_places$is_orig_place[temp_work_ids[which(works_places$publication_place[temp_work_ids] == works_places$orig_place[temp_work_ids][1])]] <- TRUE
      works_places$is_orig_place[temp_work_ids[which(works_places$publication_place[temp_work_ids] != works_places$orig_place[temp_work_ids][1])]] <- FALSE
    }
  }
  
  write.csv(works_places, "../data/work/works_places.csv", row.names = FALSE)
}


###################
# Clean data and extract data
####################

works_places$orig_place[which(works_places$orig_place == "Town")] <- "Charleston SC"
works_places$publication_place[which(works_places$publication_place == "Town")] <- "Charleston SC"


#london's total FE
canon_locs <- which(works_places$finalWorkField %in% canon$work_titles[which(canon$is_canon == TRUE)])
canon_works <- works_places$finalWorkField[canon_locs]
canon_works <- unique(canon_works)

orig_place_list <- c()
for(i in 1:length(canon_works)) {
  cat("\r", i, "in", length(canon_works))
  orig_place_list <- c(orig_place_list, works_places$orig_place[which(works_places$finalWorkField == canon_works[i])][1])
}

orig_place_list <- orig_place_list[-which(orig_place_list == "Unknown")]
canon_estcs <- works$system_control_number[which(works$finalWorkField %in% canon$work_titles[which(canon$is_canon == TRUE)])]


### FE / SE stuff
top_works <- canon$work_titles[which(canon$is_canon == TRUE)]


#top_works <- unique(works_places$finalWorkField[which(works_places$mfe_sus_multi_city == TRUE)])
edition_shift_test <- works_places[which(works_places$finalWorkField %in% top_works),]
#edition_shift_test <- works_places[-c(which(works_places$mfe_sus_multi_city == TRUE)),]
edition_shift_test <- edition_shift_test[c(which(edition_shift_test$me == TRUE)),]
edition_shift_test <- edition_shift_test[which(!is.na(edition_shift_test$publication_place)),]
edition_shift_test$publication_place <- gsub(" ", "_", edition_shift_test$publication_place)
edition_shift_test$publication_place <- gsub("-", "_", edition_shift_test$publication_place)
edition_shift_test$publication_place <- gsub("⁻", "_", edition_shift_test$publication_place)

edition_shift_test$orig_place <- gsub(" ", "_", edition_shift_test$orig_place)
edition_shift_test$orig_place <- gsub("-", "_", edition_shift_test$orig_place)
edition_shift_test$orig_place <- gsub("⁻", "_", edition_shift_test$orig_place)


names <- c(unique(edition_shift_test$publication_place), "Unknown")

place_shifts_df <- setNames(data.frame(matrix(ncol = length(names), nrow = length(names))), c(names))
place_shifts_df <- cbind(data.frame(orig_place = c(names)), place_shifts_df)
place_shifts_df <- data.frame(place_shifts_df)
place_shifts_df[,2:length(place_shifts_df)] <- 0
place_shifts_df[,2:length(place_shifts_df)] <- as.numeric(unlist(place_shifts_df[,2:length(place_shifts_df)]))

col_names <- names(place_shifts_df)

work_list <- unique(edition_shift_test$finalWorkField)

for (i in 1:length(unique(edition_shift_test$finalWorkField))) {
  #cehck if any movement
  temp_ids <- which(edition_shift_test$finalWorkField == work_list[i])
  temp_places <- edition_shift_test$publication_place[temp_ids]
  
  if(length(unique(temp_places)) == 1) { next }
  cat("\r", i, "in", length(unique(edition_shift_test$finalWorkField)))
  #fe
  fe <- edition_shift_test$orig_place[temp_ids][1]
  df_row <- which(place_shifts_df$orig_place == fe)
  
  #remove instances of same place
  temp_ids <- temp_ids[which(edition_shift_test$publication_place[temp_ids] %!in% fe)]
  temp_places <- unique(edition_shift_test$publication_place[temp_ids])
  #se (subsequent)
  place_shifts_df[df_row, which(col_names %in% temp_places)] <- place_shifts_df[df_row, which(col_names %in% temp_places)] + 1
}

#REMOVE UNKNOWN MOVEMENTS
place_shifts_df <- place_shifts_df[-c(which(place_shifts_df$orig_place == "Unknown")),]

movements_df <- data.frame(place = place_shifts_df$orig_place)
movements_df$from <- 0
movements_df$to <- 0

for(i in 1:nrow(movements_df)) {
  cat("\r", i, "in", nrow(movements_df))
  orig_temp_loc <- which(place_shifts_df$orig_place == movements_df$place[i])
  from_temp_loc <- which(colnames(place_shifts_df) == movements_df$place[i])
  movements_df$from[i] <- sum(place_shifts_df[orig_temp_loc,c(2:ncol(place_shifts_df))])
  movements_df$to[i] <- sum(place_shifts_df[,from_temp_loc])
}

movements_df$ratio <- movements_df$to/movements_df$from

#works and their cities

top_works_cities <- c()

for (i in 1:length(top_works)) {
  cat("\r", i, "in", length(top_works))
  top_works_cities <- c(top_works_cities, works_places$orig_place[which(works_places$finalWorkField == top_works[i])[1]])
}

top_works_cities_df <- data.frame(top_works, top_works_cities)

#create netowrk graph of places

#place_shifts_df <- place_shifts_df[-c(which(place_shifts_df$orig_place == "Unknown")),]

edges <- data.frame(source = character(), target = character(), weight = numeric())
for (i in 1:nrow(place_shifts_df)) {
  cat("\r",i,"in", nrow(place_shifts_df))
  source <- place_shifts_df$orig_place[i]
  targets <- names[which(place_shifts_df[i,2:ncol(place_shifts_df)] != 0)]
  weight <- unlist(place_shifts_df[i,which(place_shifts_df[i,2:ncol(place_shifts_df)] != 0)+1])
  edges <- rbind(edges, data.frame(source = rep(source, length(targets)), target = targets, weight = weight))
}

#edges <- edges[-c(which(edges$source == "Unknown")),]

temp_edges <- edges



###############################################################################
################# THIS IS CURRENTY WITHOUT A KEY AS ITS PRIVATE ###############
################# UNCOMMENT AND REPLACE KEY TO ACTUALLY RUN ###################
################# OR USE DATA WITH GIS DATA ALREADY INCLUDED ##################

# nodes <- data.frame(nodes = unique(c(temp_edges$source, temp_edges$target)))
# nodes$in_size <- 0
# nodes$out_size <- 0
# 
# for(i in 1:nrow(nodes)) {
#   cat("\r", i, "in", nrow(nodes))
#   nodes$in_size[i] <- sum(temp_edges$weight[which(temp_edges$target == nodes$nodes[i])])
#   nodes$out_size[i] <- sum(temp_edges$weight[which(temp_edges$source == nodes$nodes[i])])
# }
# 
# remove nodes with less than ten in and zero out
# bad_nodes <- nodes$nodes[intersect(which(nodes$in_size < 10), which(nodes$out_size == 0))]
# nodes <- nodes[-c(intersect(which(nodes$in_size < 10), which(nodes$out_size == 0))),]
# temp_edges <- temp_edges[-c(which(temp_edges$target %in% bad_nodes)),]

# library(ggmap)
# register_google(key = "xxxxx")
# 
# orig <- c("Paisley", "Bristol", "Leeds", "Exeter", "Preston", "Montrose", "Perth", "Birmingham", "Salisbury","Dundee",
#           "Waterford", "Ayr", "Hereford", "Blackburn", "Halifax", "Chester", "Bury", "York", "Bath", "Norwich", "Ludlow",
#           "Cork", "Oxford", "Reading", "Coventry", "Sheffield", "Liverpool", "Bolton")
# new <- c("Paisley, UK", "Bristol, UK", "Leeds, UK", "Exeter, UK", "Preston, UK", "Montrose, UK", "Perth, UK", "Birmingham, UK",
#          "Salisbury, UK", "Dundee, UK", "Waterford, Ireland", "Ayr, Scotland", "Hereford, UK", "Blackburn, UK",
#          "Halifax, UK", "Chester, UK", "Bury, UK", "York, UK", "Bath, UK", "Norwich, UK", "Ludlow, UK", "Cork, Ireland",
#          "Oxford, UK", "Reading, UK", "Coventry, UK", "Sheffield, UK", "Liverpool, UK", "Bolton, UK")
# for(i in 1:length(orig)) { nodes$nodes[which(nodes$nodes == orig[i])] <- new[i] }
# 
# length(which(movements_df$from != 0))
# 
# for(i in 1:nrow(nodes)) {
#   cat("\r", i)
#   loc <- geocode(nodes$nodes[i])
#   nodes$longitude[i] <- loc$lon
#   nodes$latitude[i] <- loc$lat
# }
# 
# for(i in 1:length(orig)) { nodes$nodes[which(nodes$nodes == new[i])] <- orig[i] }
# 
# write.csv(nodes, file="output/data/canon_move_gis.csv", row.names = FALSE)

#above, but output saved
nodes <- read.csv("../output/data/canon_move_gis.csv")

#match edges to nodes
nodes_to_keep <- unique(nodes$nodes)
edges_to_keep <- edges[which(edges$source %in% nodes_to_keep),]
edges_to_keep <- edges[which(edges$target %in% nodes_to_keep),]
temp_edges <- edges_to_keep

###############################################################################

######### CREATE GIS FILE

work_g <- graph_from_data_frame(temp_edges, directed = TRUE, vertices = nodes)

#test if data seems to be working
# library(leaflet)
# m <- leaflet() %>%
#   addTiles() %>%  # Add default OpenStreetMap map tiles
#   addMarkers(lng=nodes$longitude[1:10], lat=nodes$latitude[1:10])
# m

#rescale = function(x,a,b,c,d){c + (x-a)/(b-a)*(d-c)}

V(work_g)$out_size <- nodes$out_size
V(work_g)$in_size <- nodes$in_size
V(work_g)$label <- ifelse(nodes$in_size > 1, nodes$nodes, NA)
# plot(work_g, vertex.label = V(work_g)$label, layout = layout.fruchterman.reingold, edge.arrow.size=0.5,
#      vertex.size=rescale(V(work_g)$in_size, min(V(work_g)$in_size), max(V(work_g)$in_size), 1, 5))

saveAsGEXF = function(g, filepath="../output/data/work_movements.gexf") {
  require(igraph)
  require(rgexf)
  
  # gexf nodes require two column data frame (id, label)
  # check if the input vertices has label already present
  # if not, just have the ids themselves as the label
  if(is.null(V(g)$label))
    V(g)$label <- as.character(V(g))
  
  # similarily if edges does not have weight, add default 1 weight
  if(is.null(E(g)$weight))
    E(g)$weight <- rep.int(1, ecount(g))
  
  nodes <- data.frame(cbind(V(g), V(g)$label))
  edges <- t(Vectorize(get.edge, vectorize.args='id')(g, 1:ecount(g)))
  #test_edges <- t(Vectorize(ends, vectorize.args='id')(g, 1:ecount(g)))
  
  # combine all node attributes into a matrix (and take care of & for xml)
  vAttrNames <- setdiff(list.vertex.attributes(g), "label") 
  nodesAtt <- data.frame(sapply(vAttrNames, function(attr) sub("&", "&",get.vertex.attribute(g, attr))))
  
  # combine all edge attributes into a matrix (and take care of & for xml)
  eAttrNames <- setdiff(list.edge.attributes(g), "weight") 
  edgesAtt <- data.frame(sapply(eAttrNames, function(attr) sub("&", "&",get.edge.attribute(g, attr))))
  
  # combine all graph attributes into a meta-data
  graphAtt <- sapply(list.graph.attributes(g), function(attr) sub("&", "&",get.graph.attribute(g, attr)))
  
  # generate the gexf object
  output <- write.gexf(nodes, edges, 
                       edgesWeight=E(g)$weight,
                       edgesAtt = edgesAtt,
                       nodesAtt = nodesAtt,
                       meta=c(list(creator="Gopalakrishna Palem", description="igraph -> gexf converted file", keywords="igraph, gexf, R, rgexf"), graphAtt))
  
  print(output, filepath, replace=T)
}

saveAsGEXF(work_g)

########################
# SOME INFO ON WHAT TO DO WITH THIS DATA WITH GEPHI
# 
# Export
# Copy long/lat as double (in lab)
# Copy in_size/out_size at int (in lab)
# Labels need to be corrected with name (copy data in lab)
# Size of node = in/out size (ONE EACH FOR EACH PLOT)
# Layout = geo_layout
# Nodes can be removed with Attributes, Partition, in/out size - rangeo in > 50
#   OUT > 1
# in size .1-5
# out size .1-5 
# edge opacyity 20%
# rescale weight in preview: .01-.5
# node border width 0
######################



