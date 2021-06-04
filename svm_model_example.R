library("quanteda")
library("quanteda.textmodels")
library(googledrive)
temp_r_file <- tempfile(fileext = ".R")
temp_rds_file <- tempfile(fileext = ".rds")
d_rds_file <- drive_download(
  as_id("1E4ZPUbR98vLW5hmL0GYYQ-GYPDP7vriR"), path = temp_r_file, overwrite = TRUE)
tdm <- readRDS(d_rds_file$local_path)
tmod <- textmodel_svm(tdm, y = tdm$type, weight = "uniform", verbose=TRUE)

# https://drive.google.com/file/d/1ElBgZ0AfKZz10SGfWZBihg2lWmZFgQBS/view?usp=sharing
# https://drive.google.com/file/d/1E4ZPUbR98vLW5hmL0GYYQ-GYPDP7vriR/view?usp=sharing

