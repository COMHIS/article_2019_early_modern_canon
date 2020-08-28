library(ggplot2)
library(dplyr)
library(stringr)
library(stringi)
library(devtools)
library(DataCombine)
# library(qdap)
library(reshape2)
library(zoo)
library(tidyr)
library(ggpmisc)
library(ggspectra)
library(tidyverse)
library(RColorBrewer)
library(wesanderson) # install_github("karthik/wesanderson")
library(cowplot)
library(ggpubr)
library(hexbin)
library(lattice)
library(plyr)
library(reshape2)
library(XML)
# library(netdiffuseR)
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
# library('rwantshue')
library(ggthemes) 
library(knitr)
library(tidyr)


rename <- dplyr::rename
summarize <- dplyr::summarize
mutate <- dplyr::mutate
source("commonlibs_r/output.R")

# TODO: install from local or Github
#devtools::install("comhis") # github/comhis/comhis
library(comhis)

#devtools::install("bibliographica") # github/comhis/bibliographica
library(bibliographica)

#source("funcs.R")
Sys.setlocale(locale="UTF-8") 

# ggplot theme
theme_set(theme_bw(20))
# theme_set(theme_comhis(type="continuous", base_size=12, family="Helvetica"))

actors_csv = "../data/raw/unified_actors.csv"
actorlinks_csv = "../data/raw/unified_actorlinks_enriched.csv"
workdata_csv = "../data/raw/estc_works_roles.csv"
pubyears_csv = "../data/raw/publicationyears.csv"
estc_titles_csv = "../data/raw/estc_processed.csv"
subject_topic_data_csv = '../data/work/work_subject_topics_combined.csv'
canon_csv = "../data/work/canon.csv"

