#install packages needed (not via "install.packages")

install.packages("devtools")
install.packages("readxl")
install.packages("tidyverse")
install.packages("ggfortify")
install.packages("ggeffects")
install.packages("ggnewscale")
install.packages("vegan")
install.packages("ggtern")
install.packages("dichromat")
install.packages("compositions")
install.packages("robCompositions")
devtools::install_github("pmartinezarbizu/pairwiseAdonis/pairwiseAdonis")
install.packages("picante")
install.packages("glm2")

##Bioconductor
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = "3.19")

##phyloseq
if(!requireNamespace("BiocManager")){
  install.packages("BiocManager")
  }
BiocManager::install("phyloseq")

##qiime2R
if (!requireNamespace("devtools", quietly = TRUE)){install.packages("devtools")}
devtools::install_github("jbisanz/qiime2R")



###yet to be done
##fantaxtic
if(!"devtools" %in% installed.packages()){
  install.packages("devtools")
}
devtools::install_github("gmteunisse/fantaxtic")

##ggnested
if(!"devtools" %in% installed.packages()){
  install.packages("devtools")
}
devtools::install_github("gmteunisse/ggnested")

##biomformat
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("biomformat")

#XLconnect
install.packages("XLConnect")

#readGenAlEx
install.packages("devtools")
#devtools::install_github("douglasgscofield/readGenalex")

#ANOCOM-BC
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("ANCOMBC")

#microbiome
##needed for ANCOM-BC
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("microbiome")