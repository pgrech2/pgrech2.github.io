# Paul Grech
# Project 3
library("shiny")
library("dplyr")

# Read in data
data1 = read.csv('data/1_filtered.csv')
data3 = read.csv('data/3_filtered.csv')
data4 = read.csv('data/4_filtered.csv')
data5 = read.csv('data/5_filtered.csv')
data6 = read.csv('data/6_filtered.csv')
data8 = read.csv('data/8_filtered.csv')
data9 = read.csv('data/9_filtered.csv')

# Combine Data
KnotData = rbind(data1, data3, data4, data5, data6, data8, data9)
KnotData = tbl_df(KnotData)

# Make URL character such that link is active for shiny application
KnotData$Websites <- sapply(KnotData$Websites, as.character)

# Format link so that it is active in shiny application
KnotData$Websites <- paste0("<a href=",KnotData$Websites,">",'Link',"</a>")

# Drop Index
KnotData = KnotData[-1]

runApp('App')



