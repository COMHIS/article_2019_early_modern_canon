#sna_functions

library(RColorBrewer)

prepare_work_graph <- function(work, location = "london", only_main = FALSE, link_groups = FALSE, role = "") {
  
  
  #Prepare edges/nodes
  work_ids <- works$system_control_number[which(works$finalWorkField %in% work)]
  if(any(location != "")) {
    work_places <- pub_location$system_control_number[which(tolower(pub_location$publication_place) %in% tolower(location))]
    work_ids <- intersect(work_ids, work_places)
  }
  if(length(work_ids) < 1) { next }
  work_links <- actor_links[c(which(actor_links$curives %in% work_ids)),]
  if(any(role == "publisher")) {
    work_links <- work_links[c(which(work_links$actor_role_publisher == "True")),]
  }
  if(nrow(work_links) < 1) { next }
  work_graph <- data.frame(target = work_links$curives, stringsAsFactors = FALSE)
  work_graph$source <- work_links$actor_id
  unique_nodes <- unique(work_graph$target)
  unique_nodes <- c(unique_nodes, unique(work_graph$source))
  nodes <- data.frame(name = unique_nodes)
  nodes$year <- FALSE
  nodes$real_name <- NA
  nodes$place <- NA
  nodes$wf <- NA
  nodes$fe <- FALSE
  
  #get years
  temp_works <- unique(work_graph$target)
  for (i in 1:length(temp_works)) {
    nodes$year[which(nodes$name == temp_works[i])] <- 
      #works$publication_year[which(works$system_control_number == temp_works[i])]
      works$publication_year[which(works$system_control_number == temp_works[i])]
  }
     
  # This is perhaps slightly cleaner, maybe quicker?     
  #     nodes$year[which(nodes$name == temp_works[i])] <-
  #       test <- lapply(temp_works, function(x) {works$publication_year[which(works$system_control_number == x)[1]]})
  #   
  #   
  #   
  #   ifelse(length(actor_data$name_unified[which(x == actor_data$actor_id)]) == 0, x, actor_data$name_unified[which(x == actor_data$actor_id)])
  #   
  # }
  
  #get places
  temp_works <- unique(work_graph$target)
  for (i in 1:length(temp_works)) {
    nodes$place[which(nodes$name == temp_works[i])] <- 
      #  works$publication_place[which(works$system_control_number == temp_works[i])]
      pub_location$publication_place[which(pub_location$system_control_number == temp_works[i])]
      #works$publication_place[which(works$system_control_number == temp_works[i])]
  }
  
  #get names
  temp_works <- unique(work_graph$source)
  nodes$real_name <- nodes$name
  #BELOW NECESSARY WHEN NOT USING THE NAMES, BUT INSTEAD IDS
  for (i in 1:length(temp_works)) {
    nodes$real_name[which(nodes$name == temp_works[i])] <-
      ifelse(length(actor_data$name_unified[which(actor_data$actor_id == temp_works[i])]) > 0,
      actor_data$name_unified[which(actor_data$actor_id == temp_works[i])], NA)
  }
  
  #get wf
  temp_works <- unique(work_graph$target)
  for (i in 1:length(temp_works)) {
    nodes$wf[which(nodes$name == temp_works[i])] <- 
      works$finalWorkField[which(works$system_control_number == temp_works[i])]
  }
  
  if (link_groups == TRUE) {
    if(any(work_graph$target %in% publisher_groups$actor_id | work_graph$source %in% publisher_groups$actor_id)) {
      pub_group_targets <- work_graph$target[which(work_graph$target %in% publisher_groups$actor_id)]
      pub_group_sources <- work_graph$source[which(work_graph$source %in% publisher_groups$actor_id)]
      group_actors <- c(pub_group_targets, pub_group_sources)
      group_actors <- group_actors[-c(duplicated(group_actors))]
      #which groups
      pub_groups <- unique(publisher_groups$group[which(publisher_groups$actor_id %in% group_actors)])
      for(i_pub in 1:length(pub_groups)) {
        #cat("\n", i_pub, "\n")
        matches <- group_actors[which(group_actors %in% publisher_groups$actor_id[which(publisher_groups$group == pub_groups[i_pub])])]
        if(length(matches[-which((duplicated(matches)))]) != 0) {
          matches <- matches[-which((duplicated(matches)))]  
        }
        if(length(matches) > 1) {
          for(i_pub_loop in 1:length(matches)) {
            #cat("\r", i_pub_loop)
            #temp_df <- data.frame(target=rep(matches[i_pub_loop], length(matches)), source=matches, weight=rep(3, length(matches)))
            temp_df <- data.frame(target=rep(matches[i_pub_loop], length(matches)), source=matches)
            #temp_df <- temp_df[-c(which(duplicated(temp_df))),]
            work_graph <- rbind(work_graph, temp_df)
          }
        }
      }
    }
  }
  work_g <- graph_from_data_frame(work_graph, directed = FALSE, vertices = nodes)
  work_g <<- work_g
  work_graph <<- work_graph
  nodes <<- nodes
  
  if(only_main == TRUE) {
    V(work_g)$comp <- components(work_g)$membership
    work_g <<- induced_subgraph(work_g,V(work_g)$comp==names(sort(table(V(work_g)$comp),decreasing=TRUE)[1]))
  }
  
}

g_year_fade <- function(x, only_main = FALSE, location = "london", check_links = FALSE, role = "") {
  
  prepare_work_graph(x, location, only_main)
  
  if(check_links == TRUE) {
    work_graph$weight <- 1
    
    #CHECK KNOWN PUBLISHER GROUPS
    if(any(work_graph$target %in% publisher_groups$actor_id | work_graph$source %in% publisher_groups$actor_id)) {
      pub_group_targets <- work_graph$target[which(work_graph$target %in% publisher_groups$actor_id)]
      pub_group_sources <- work_graph$source[which(work_graph$source %in% publisher_groups$actor_id)]
      group_actors <- c(pub_group_targets, pub_group_sources)
      group_actors <- group_actors[-c(duplicated(group_actors))]
      #which groups
      pub_groups <- unique(publisher_groups$group[which(publisher_groups$actor_id %in% group_actors)])
      for(i_pub in 1:length(pub_groups)) {
        #cat("\n", i_pub, "\n")
        matches <- group_actors[which(group_actors %in% publisher_groups$actor_id[which(publisher_groups$group == pub_groups[i_pub])])]
        if(length(matches[-which((duplicated(matches)))]) != 0) {
          matches <- matches[-which((duplicated(matches)))]  
        }
        if(length(matches) > 1) {
          for(i_pub_loop in 1:length(matches)) {
            #cat("\r", i_pub_loop)
            temp_df <- data.frame(target=rep(matches[i_pub_loop], length(matches)), source=matches, weight=rep(3, length(matches)))
            #temp_df <- data.frame(target=rep(matches[i_pub_loop], length(matches)), source=matches)
            #temp_df <- temp_df[-c(which(duplicated(temp_df))),]
            work_graph <- rbind(work_graph, temp_df)
          }
        }
      }
    }
    
    #CHECK LINKS WITH OTHER ACTORS IN GRAPH
    g.clusters <- clusters(work_g)
    for (i in 1:g.clusters$no) {
      temp.cluster <- names(which(g.clusters$membership == i))
      temp.others <- names(which(g.clusters$membership != i))
      for (x in 1:length(temp.cluster)) {
        if(grepl("CU-RivES", temp.cluster[x])) { next }
        
        if(any(temp.others %in% book_trade_links$target[which(book_trade_links$source == temp.cluster[x])])) {
          matches <- temp.others[which(temp.others %in% book_trade_links$target[which(book_trade_links$source == temp.cluster[x])])]
          if(length(matches) > 0) {
            temp_df <- data.frame(target = rep(temp.cluster[x], length(matches)), source = matches, 
                                  weight = rep(2, length(matches)))
            work_graph <- rbind(work_graph, temp_df)
          }
        }
        if(any(temp.others %in% book_trade_links$source[which(book_trade_links$target == temp.cluster[x])])) {
          matches <- temp.others[which(temp.others %in% book_trade_links$source[which(book_trade_links$target == temp.cluster[x])])]
          if(length(matches) > 0) {
            temp_df <- data.frame(target = rep(temp.cluster[x], length(matches)), source = matches, 
                                  weight = rep(2, length(matches)))
            work_graph <- rbind(work_graph, temp_df)
          }
        }
      }
    }
    #PREPARE EDGES
    work_g <- graph_from_data_frame(work_graph, directed = FALSE, vertices = nodes)
    E(work_g)$type <- NA
    E(work_g)$type[which(E(work_g)$weight == "1")] <- "1"
    E(work_g)$type[which(E(work_g)$weight == "2")] <- "2"
    E(work_g)$type[which(E(work_g)$weight == "3")] <- "3"
    
    E(work_g)$lty[E(work_g)$type == 1] <- 1
    E(work_g)$color[E(work_g)$type == 1] <- "grey"
    E(work_g)$lty[E(work_g)$type == 2] <- 2
    E(work_g)$color[E(work_g)$type == 2] <- "blue"
    E(work_g)$lty[E(work_g)$type == 3] <- 2
    E(work_g)$color[E(work_g)$type == 3] <- "red"
    
    #MAKE G
    work_g <- simplify(work_g, remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb = list("first"))
    
  } else {
    work_g <- graph_from_data_frame(work_graph, directed = FALSE, vertices = nodes)
  }
  
  if(only_main == TRUE) {
    V(work_g)$comp <- components(work_g)$membership
    work_g <- induced_subgraph(work_g,V(work_g)$comp==names(sort(table(V(work_g)$comp),decreasing=TRUE)[1]))
  }
  
  V(work_g)$color <- "blue"
  num_works <- unique(nodes$wf)
  num_works <- num_works[which(!is.na(num_works))]
  
  range_years <- c(V(work_g)$year)
  range_years <- range_years[-c(which(range_years==FALSE))]
  range_years <- range(range_years)
  if(round(as.numeric(range_years[2])-as.numeric(range_years[1])) < 20) {
    year_split <- round(round(as.numeric(range_years[2])-as.numeric(range_years[1])))
    colfunc<-colorRampPalette(c("yellow","red"))
    col = (colfunc(year_split))
    current_start <- as.numeric(range_years)[1]
    for (i in 1:year_split) {
      if(i == year_split) {
        current_end <- range_years[2]
      } else  {
        current_end <- current_start + 1
      }
      #cat(current_start, current_end, "\n")
      V(work_g)$color[intersect(which(V(work_g)$year >= current_start), which(V(work_g)$year <= current_end))] <-
        col[i]
      current_start <- current_end
    }
  } else {
    year_split <- (as.numeric(range_years[2])-as.numeric(range_years[1])) / 20
    colfunc<-colorRampPalette(c("yellow","red"))
    col = (colfunc(20))
    current_start <- as.numeric(range_years)[1]
    for (i in 1:20) {
      if(i == 20) {
        current_end <- range_years[2]
      } else  {
        current_end <- current_start + year_split
      }
      #cat(current_start, current_end, "\n")
      V(work_g)$color[intersect(which(V(work_g)$year >= current_start), which(V(work_g)$year <= current_end))] <-
        col[i]
      current_start <- current_start + year_split 
    }
  }
  
  # colfunc<-colorRampPalette(c("yellow","red"))
  # col = (colfunc(year_split))
  # current_start <- as.numeric(range_years)[1]
  # for (i in 1:year_split) {
  #   current_end <- current_start + year_split
  #   #cat(current_start, current_end, "\n")
  #   V(work_g)$color[intersect(which(V(work_g)$year >= current_start), which(V(work_g)$year <= current_end))] <-
  #     col[i]
  #   current_start <- current_end + 1
  # }
  
  V(work_g)$year <- V(work_g)$year
  V(work_g)$place <- V(work_g)$place
  
  #first editions of each work
  for (i in 1:length(num_works)) {
    temp_works <- which(V(work_g)$wf == num_works[i])
    temp_years <- V(work_g)$year[temp_works]
    min_year <- min(temp_years)
    V(work_g)$fe[temp_works[which(V(work_g)$year[temp_works] == min_year)]] <- TRUE
  }
  
  cat("output: output_g")
  output_g <<- work_g
  
}

g_by_work <- function(x, only_main = FALSE, location = "london", check_links = FALSE) {
  prepare_work_graph(x, location)
  if(check_links == TRUE) {
    work_graph$weight <- 1
    
    #CHECK KNOWN PUBLISHER GROUPS
    if(any(work_graph$target %in% publisher_groups$actor_id | work_graph$source %in% publisher_groups$actor_id)) {
      pub_group_targets <- work_graph$target[which(work_graph$target %in% publisher_groups$actor_id)]
      pub_group_sources <- work_graph$source[which(work_graph$source %in% publisher_groups$actor_id)]
      group_actors <- c(pub_group_targets, pub_group_sources)
      group_actors <- group_actors[-c(duplicated(group_actors))]
      #which groups
      pub_groups <- unique(publisher_groups$group[which(publisher_groups$actor_id %in% group_actors)])
      for(i_pub in 1:length(pub_groups)) {
        #cat("\n", i_pub, "\n")
        matches <- group_actors[which(group_actors %in% publisher_groups$actor_id[which(publisher_groups$group == pub_groups[i_pub])])]
        if(length(matches[-which((duplicated(matches)))]) != 0) {
          matches <- matches[-which((duplicated(matches)))]  
        }
        if(length(matches) > 1) {
          for(i_pub_loop in 1:length(matches)) {
            #cat("\r", i_pub_loop)
            temp_df <- data.frame(target=rep(matches[i_pub_loop], length(matches)), source=matches, weight=rep(3, length(matches)))
            #temp_df <- data.frame(target=rep(matches[i_pub_loop], length(matches)), source=matches)
            #temp_df <- temp_df[-c(which(duplicated(temp_df))),]
            work_graph <- rbind(work_graph, temp_df)
          }
        }
      }
    }
    
    #CHECK LINKS WITH OTHER ACTORS IN GRAPH
    g.clusters <- clusters(work_g)
    for (i in 1:g.clusters$no) {
      temp.cluster <- names(which(g.clusters$membership == i))
      temp.others <- names(which(g.clusters$membership != i))
      for (x in 1:length(temp.cluster)) {
        if(grepl("CU-RivES", temp.cluster[x])) { next }
        
        if(any(temp.others %in% book_trade_links$target[which(book_trade_links$source == temp.cluster[x])])) {
          matches <- temp.others[which(temp.others %in% book_trade_links$target[which(book_trade_links$source == temp.cluster[x])])]
          if(length(matches) > 0) {
            temp_df <- data.frame(target = rep(temp.cluster[x], length(matches)), source = matches, 
                                  weight = rep(2, length(matches)))
            work_graph <- rbind(work_graph, temp_df)
          }
        }
        if(any(temp.others %in% book_trade_links$source[which(book_trade_links$target == temp.cluster[x])])) {
          matches <- temp.others[which(temp.others %in% book_trade_links$source[which(book_trade_links$target == temp.cluster[x])])]
          if(length(matches) > 0) {
            temp_df <- data.frame(target = rep(temp.cluster[x], length(matches)), source = matches, 
                                  weight = rep(2, length(matches)))
            work_graph <- rbind(work_graph, temp_df)
          }
        }
      }
    }
    
    #PREPARE EDGES
    work_g <- graph_from_data_frame(work_graph, directed = FALSE, vertices = nodes)
    E(work_g)$type <- NA
    E(work_g)$type[which(E(work_g)$weight == "1")] <- "1"
    E(work_g)$type[which(E(work_g)$weight == "2")] <- "2"
    E(work_g)$type[which(E(work_g)$weight == "3")] <- "3"
    
    E(work_g)$lty[E(work_g)$type == 1] <- 1
    E(work_g)$color[E(work_g)$type == 1] <- "grey"
    E(work_g)$lty[E(work_g)$type == 2] <- 2
    E(work_g)$color[E(work_g)$type == 2] <- "blue"
    E(work_g)$lty[E(work_g)$type == 3] <- 2
    E(work_g)$color[E(work_g)$type == 3] <- "red"
    
    #MAKE G
    work_g <- simplify(work_g, remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb = list("first"))
  }
  if(only_main == TRUE) {
    V(work_g)$comp <- components(work_g)$membership
    work_g <- induced_subgraph(work_g,V(work_g)$comp==names(sort(table(V(work_g)$comp),decreasing=TRUE)[1]))
  }
  
  V(work_g)$color <- "blue"
  
  #ASSIGN COLOURS TO WORKS
  num_works <- unique(nodes$wf)
  num_works <<- num_works[which(!is.na(num_works))]
  qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
  col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
  col_vector <<- col_vector
  
  #colours <- c("red", "orange", "pink", "green", "purple", "cyan", "yellow")
  for (i in 1:length(num_works)) {
    V(work_g)$color[which(V(work_g)$wf == num_works[i])] <- col_vector[i]
  }
  
  #V(work_g)$year <- NA
  V(work_g)$year <- V(work_g)$year
  V(work_g)$place <- V(work_g)$place
  
  #first editions of each work
  for (i in 1:length(num_works)) {
    temp_works <- which(V(work_g)$wf == num_works[i])
    temp_years <- V(work_g)$year[temp_works]
    min_year <- min(temp_years)
    V(work_g)$fe[temp_works[which(V(work_g)$year[temp_works] == min_year)]] <- TRUE
  }
  output_g <<- work_g
  cat("output: output_g")
}

g_by_location <- function(x, only_main = FALSE, location = "", check_links = FALSE) {
  prepare_work_graph(x, location)
  
  if(check_links == TRUE) {
    work_graph$weight <- 1
    
    #CHECK KNOWN PUBLISHER GROUPS
    if(any(work_graph$target %in% publisher_groups$actor_id | work_graph$source %in% publisher_groups$actor_id)) {
      pub_group_targets <- work_graph$target[which(work_graph$target %in% publisher_groups$actor_id)]
      pub_group_sources <- work_graph$source[which(work_graph$source %in% publisher_groups$actor_id)]
      group_actors <- c(pub_group_targets, pub_group_sources)
      group_actors <- group_actors[-c(duplicated(group_actors))]
      #which groups
      pub_groups <- unique(publisher_groups$group[which(publisher_groups$actor_id %in% group_actors)])
      for(i_pub in 1:length(pub_groups)) {
        #cat("\n", i_pub, "\n")
        matches <- group_actors[which(group_actors %in% publisher_groups$actor_id[which(publisher_groups$group == pub_groups[i_pub])])]
        if(length(matches[-which((duplicated(matches)))]) != 0) {
          matches <- matches[-which((duplicated(matches)))]  
        }
        if(length(matches) > 1) {
          for(i_pub_loop in 1:length(matches)) {
            #cat("\r", i_pub_loop)
            temp_df <- data.frame(target=rep(matches[i_pub_loop], length(matches)), source=matches, weight=rep(3, length(matches)))
            #temp_df <- data.frame(target=rep(matches[i_pub_loop], length(matches)), source=matches)
            #temp_df <- temp_df[-c(which(duplicated(temp_df))),]
            work_graph <- rbind(work_graph, temp_df)
          }
        }
      }
    }
    
    #CHECK LINKS WITH OTHER ACTORS IN GRAPH
    g.clusters <- clusters(work_g)
    for (i in 1:g.clusters$no) {
      temp.cluster <- names(which(g.clusters$membership == i))
      temp.others <- names(which(g.clusters$membership != i))
      for (x in 1:length(temp.cluster)) {
        if(grepl("CU-RivES", temp.cluster[x])) { next }
        
        if(any(temp.others %in% book_trade_links$target[which(book_trade_links$source == temp.cluster[x])])) {
          matches <- temp.others[which(temp.others %in% book_trade_links$target[which(book_trade_links$source == temp.cluster[x])])]
          if(length(matches) > 0) {
            temp_df <- data.frame(target = rep(temp.cluster[x], length(matches)), source = matches, 
                                  weight = rep(2, length(matches)))
            work_graph <- rbind(work_graph, temp_df)
          }
        }
        if(any(temp.others %in% book_trade_links$source[which(book_trade_links$target == temp.cluster[x])])) {
          matches <- temp.others[which(temp.others %in% book_trade_links$source[which(book_trade_links$target == temp.cluster[x])])]
          if(length(matches) > 0) {
            temp_df <- data.frame(target = rep(temp.cluster[x], length(matches)), source = matches, 
                                  weight = rep(2, length(matches)))
            work_graph <- rbind(work_graph, temp_df)
          }
        }
      }
    }
    
    #PREPARE EDGES
    work_g <- graph_from_data_frame(work_graph, directed = FALSE, vertices = nodes)
    E(work_g)$type <- NA
    E(work_g)$type[which(E(work_g)$weight == "1")] <- "1"
    E(work_g)$type[which(E(work_g)$weight == "2")] <- "2"
    E(work_g)$type[which(E(work_g)$weight == "3")] <- "3"
    
    E(work_g)$lty[E(work_g)$type == 1] <- 1
    E(work_g)$color[E(work_g)$type == 1] <- "grey"
    E(work_g)$lty[E(work_g)$type == 2] <- 2
    E(work_g)$color[E(work_g)$type == 2] <- "blue"
    E(work_g)$lty[E(work_g)$type == 3] <- 2
    E(work_g)$color[E(work_g)$type == 3] <- "red"
    
    #MAKE G
    work_g <- simplify(work_g, remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb = list("first"))
  }
  
  if(only_main == TRUE) {
    V(work_g)$comp <- components(work_g)$membership
    work_g <- induced_subgraph(work_g,V(work_g)$comp==names(sort(table(V(work_g)$comp),decreasing=TRUE)[1]))
  }
  
  V(work_g)$color <- "blue"
  
  #ASSIGN COLOURS TO LOCATIONS
  num_places <- unique(nodes$place)
  num_places <- num_places[which(!is.na(num_places))]
  qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
  col_vector <<- unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
  
  #colours <- c("red", "orange", "pink", "green", "purple", "cyan", "yellow")
  for (i in 1:length(num_places)) {
    V(work_g)$color[which(V(work_g)$place == num_places[i])] <- col_vector[i]
  }
  
  #V(work_g)$year <- NA
  V(work_g)$year <- V(work_g)$year
  V(work_g)$place <- V(work_g)$place
  
  
  num_works <- unique(nodes$wf)
  num_works <- num_works[which(!is.na(num_works))]
  #first editions of each work
  for (i in 1:length(num_works)) {
    temp_works <- which(V(work_g)$wf == num_works[i])
    temp_years <- V(work_g)$year[temp_works]
    min_year <- min(temp_years)
    V(work_g)$fe[temp_works[which(V(work_g)$year[temp_works] == min_year)]] <- TRUE
  }
  output_g <<- work_g
  cat("output: output_g")
  num_places <<- num_places
}

g_check_links <- function(work, only_main = FALSE, location = "london") {
  
  prepare_work_graph(work, location)
  
  work_graph$weight <- 1
  
  #CHECK KNOWN PUBLISHER GROUPS
  if(any(work_graph$target %in% publisher_groups$actor_id | work_graph$source %in% publisher_groups$actor_id)) {
    pub_group_targets <- work_graph$target[which(work_graph$target %in% publisher_groups$actor_id)]
    pub_group_sources <- work_graph$source[which(work_graph$source %in% publisher_groups$actor_id)]
    group_actors <- c(pub_group_targets, pub_group_sources)
    group_actors <- group_actors[-c(duplicated(group_actors))]
    #which groups
    pub_groups <- unique(publisher_groups$group[which(publisher_groups$actor_id %in% group_actors)])
    for(i_pub in 1:length(pub_groups)) {
      #cat("\n", i_pub, "\n")
      matches <- group_actors[which(group_actors %in% publisher_groups$actor_id[which(publisher_groups$group == pub_groups[i_pub])])]
      if(length(matches[-which((duplicated(matches)))]) != 0) {
        matches <- matches[-which((duplicated(matches)))]  
      }
      if(length(matches) > 1) {
        for(i_pub_loop in 1:length(matches)) {
          #cat("\r", i_pub_loop)
          temp_df <- data.frame(target=rep(matches[i_pub_loop], length(matches)), source=matches, weight=rep(3, length(matches)))
          #temp_df <- data.frame(target=rep(matches[i_pub_loop], length(matches)), source=matches)
          #temp_df <- temp_df[-c(which(duplicated(temp_df))),]
          work_graph <- rbind(work_graph, temp_df)
        }
      }
    }
  }
  
  #CHECK LINKS WITH OTHER ACTORS IN GRAPH
  g.clusters <- clusters(work_g)
  for (i in 1:g.clusters$no) {
    temp.cluster <- names(which(g.clusters$membership == i))
    temp.others <- names(which(g.clusters$membership != i))
    for (x in 1:length(temp.cluster)) {
      if(grepl("CU-RivES", temp.cluster[x])) { next }
      
      if(any(temp.others %in% book_trade_links$target[which(book_trade_links$source == temp.cluster[x])])) {
        matches <- temp.others[which(temp.others %in% book_trade_links$target[which(book_trade_links$source == temp.cluster[x])])]
        if(length(matches) > 0) {
          temp_df <- data.frame(target = rep(temp.cluster[x], length(matches)), source = matches, 
                                weight = rep(2, length(matches)))
          work_graph <- rbind(work_graph, temp_df)
        }
      }
      if(any(temp.others %in% book_trade_links$source[which(book_trade_links$target == temp.cluster[x])])) {
        matches <- temp.others[which(temp.others %in% book_trade_links$source[which(book_trade_links$target == temp.cluster[x])])]
        if(length(matches) > 0) {
          temp_df <- data.frame(target = rep(temp.cluster[x], length(matches)), source = matches, 
                                weight = rep(2, length(matches)))
          work_graph <- rbind(work_graph, temp_df)
        }
      }
    }
  }
  
  #PREPARE EDGES
  work_g <- graph_from_data_frame(work_graph, directed = FALSE, vertices = nodes)
  E(work_g)$type <- NA
  E(work_g)$type[which(E(work_g)$weight == "1")] <- "1"
  E(work_g)$type[which(E(work_g)$weight == "2")] <- "2"
  E(work_g)$type[which(E(work_g)$weight == "3")] <- "3"
  
  E(work_g)$lty[E(work_g)$type == 1] <- 1
  E(work_g)$color[E(work_g)$type == 1] <- "grey"
  E(work_g)$lty[E(work_g)$type == 2] <- 2
  E(work_g)$color[E(work_g)$type == 2] <- "blue"
  E(work_g)$lty[E(work_g)$type == 3] <- 2
  E(work_g)$color[E(work_g)$type == 3] <- "red"
  
  #MAKE G
  work_g <- simplify(work_g, remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb = list("first"))
  
  #SIMPLIFY IF NECESSARY
  if(only_main == TRUE) {
    V(work_g)$comp <- components(work_g)$membership
    work_g <- induced_subgraph(work_g,V(work_g)$comp==names(sort(table(V(work_g)$comp),decreasing=TRUE)[1]))
  }
  
  V(work_g)$color <- "blue"
  num_works <- unique(nodes$wf)
  num_works <- num_works[which(!is.na(num_works))]
  
  range_years <- c(V(work_g)$year)
  range_years <- range_years[-c(which(range_years==FALSE))]
  range_years <- range(range_years)
  if(round(as.numeric(range_years[2])-as.numeric(range_years[1])) < 20) {
    year_split <- round(round(as.numeric(range_years[2])-as.numeric(range_years[1])))
    colfunc<-colorRampPalette(c("yellow","red"))
    col = (colfunc(year_split))
    current_start <- as.numeric(range_years)[1]
    for (i in 1:year_split) {
      current_end <- current_start + 1
      #cat(current_start, current_end, "\n")
      V(work_g)$color[intersect(which(V(work_g)$year >= current_start), which(V(work_g)$year <= current_end))] <-
        col[i]
      current_start <- current_end
    }
  } else {
    year_split <- round((as.numeric(range_years[2])-as.numeric(range_years[1])) / 20)
    colfunc<-colorRampPalette(c("yellow","red"))
    col = (colfunc(year_split))
    current_start <- as.numeric(range_years)[1]
    for (i in 1:year_split) {
      current_end <- current_start + year_split
      #cat(current_start, current_end, "\n")
      V(work_g)$color[intersect(which(V(work_g)$year >= current_start), which(V(work_g)$year <= current_end))] <-
        col[i]
      current_start <- current_end + 1
    }
  }
  
  V(work_g)$year <- V(work_g)$year
  V(work_g)$place <- V(work_g)$place
  
  #first editions of each work
  for (i in 1:length(num_works)) {
    temp_works <- which(V(work_g)$wf == num_works[i])
    temp_years <- V(work_g)$year[temp_works]
    min_year <- min(temp_years)
    V(work_g)$fe[temp_works[which(V(work_g)$year[temp_works] == min_year)]] <- TRUE
  }
  
  cat("output: linked_work_g")
  linked_work_g <<- work_g
}

# #TO DO
# compare_networks <- function(ids, location = "london", check_links = FALSE) {
#   
# }

plot_g <- function(x, labels = TRUE, layout = "fruchterman.reingold", title = "", legend = "years") {
  work_g <- x
  if(labels == TRUE) {
    v.label <- ifelse(V(work_g)$year != FALSE, NA, V(work_g)$real_name)
  } else {
    v.label <- NA
  }
  if(layout == "lgl") {
    p.layout <- layout.lgl
  } else if (layout == "fruchterman.reingold") {
    p.layout <- layout.fruchterman.reingold
  } else {
    p.layout <- layout.fruchterman.reingold
  }
  plot(work_g,
       vertex.label = v.label,  
       #vertex.label = ifelse(V(work_g)$year != FALSE, NA, V(work_g)$real_name),
       #vertex.label = ifelse(V(work_g)$year != FALSE, paste(V(work_g)$year), V(work_g)$real_name),
       vertex.size = ifelse(V(work_g)$year != FALSE, 4, 2),
       vertex.shape = ifelse(V(work_g)$fe == TRUE, "csquare", "circle"),
       vertex.label.cex = .8, vertex.label.color="black",
       #mark.groups=list(c(which(V(work_g)$year == min(V(work_g)$year[which(V(work_g)$year != 0)])))),
       #mark.col=c("#C5E5E7"), mark.border=NA,
       layout=p.layout)
       #layout=layout.fruchterman.reingold)
       #layout=layout.lgl)
  title(title,cex.main=2,col.main="black")
  if (legend == "years") {
    range_years <- c(V(work_g)$year)
    range_years <- range_years[-c(which(range_years==FALSE))]
    range_years <- range(range_years)
    jumps <- (as.numeric(range_years[2])-as.numeric(range_years[1]))/4
    range_years <- c(range_years[1],
                     round(as.numeric(range_years[1])+jumps),
                     round(as.numeric(range_years[1])+jumps*2),
                     round(as.numeric(range_years[1])+jumps*3),
                     round(as.numeric(range_years[1])+jumps*4))
    colfunc<-colorRampPalette(c("yellow","red"))
    col = (colfunc(20))
    legend("bottomleft", legend=range_years, col = col[c(1,5,10,15,20)], bty = "n", pch=20 , pt.cex = 1, cex = 1, text.col="black" , inset = c(-0.1, -0.1))
  } else if (legend == "places") {
    legend("bottomleft", legend=num_places, col = col_vector[1:length(num_places)], bty = "n", pch=20 , pt.cex = 2, cex = .8, text.col="black" , inset = c(-0.1, -0.1))
  } else if (legend == "works") {
    num_works <- gsub("^[0-9]+[-]", "", num_works)
    num_works <- paste0(substr(num_works, 1, 20), "...")
    legend("bottomleft", legend=num_works, col = col_vector[1:length(num_works)], bty = "n", pch=20 , pt.cex = 2, cex = .8, text.col="black" , inset = c(-0.35, 0))
  }
}

author_works <- function(x) {
  work_ids <- author_data$estc_id[which(author_data$corrected_id == x)]
  author_tag <- author_data$estc_id[which(author_data$role == "Author")]
  work_ids <- intersect(work_ids, author_tag)
  authors_works_list <<- unique(works$finalWorkField[which(works$system_control_number %in% work_ids)])
}

