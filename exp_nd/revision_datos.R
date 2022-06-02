library(ggplot2)
library(dplyr)

require("data.table")
require("rlist")

require("rpart")
require("parallel")

#limpio la memoria
rm( list=ls() )  #remove all objects
gc()             #garbage collection

setwd("C:\\Users\\natal\\Documents\\Mineriadatos\\")  
#cargo el dataset
dataset  <- fread("./datasets/paquete_premium_202011.csv")   #donde entreno

summary(dataset)
