# Project 2 - Mass Shootings Shiny App
# By Paul Grech and Chris Neimeth


# RUN APP
library(shiny)
runApp("App")

################################################################################################
# FOLLOWING USED TO CREATE DATA SET FOR APP

#### LIBRARIES
library(shiny)
library(reshape2)
library(gdata)
library(openxlsx)
library(dplyr)
library(ggplot2)
library(ggmap)


################################################################################################
##### DATA IMPORT
Import2015 <- read.csv("Data/2015CURRENT.csv", header=TRUE)
Import2014 <- read.csv("Data/2014MASTER.csv", header=TRUE)
Import2013 <- read.csv("Data/2013MASTER.csv", header=TRUE)
Import1966 <- read.csv("Data/stanfordnew.csv", header = TRUE)

##### DATA CLEANING 2013 - 2015 
names(Import2015)
Data2015 <- Import2015[, c(2, 4:7)]
names(Data2015)[2] <- "Killed"
names(Data2015)[3] <- "Wounded"

names(Import2014)
Data2014 <- Import2014[, c(2, 4:7)]
names(Data2014)[2] <- "Killed"
names(Data2014)[3] <- "Wounded"

names(Import2013)
Data2013 <- Import2013[, c(2, 4:7)]
names(Data2013) <- c("Date", "Killed", "Wounded", "Location", "Article")

Data13.15 <- rbind(Data2013, Data2014, Data2015)

##### DATA CLEANING 1966
Data1966 <- tbl_df(Import1966)
names(Data1966) <- toupper((names(Data1966)))
Data1966 <- Data1966[,c("DAY.OF.WEEK", "DATE", "CASEID", "TITLE", "DESCRIPTION", "CITY", "STATE", 
                        "NUMBER.OF.VICTIM.FATALITIES", "NUMBER.OF.VICTIMS.INJURED", 
                        "SHOOTER.AGE.S.", "SHOOTER.SEX", "SHOOTER.RACE", "RELATIONSHIP.TO.INCIDENT.LOCATION", 
                        "FATE.OF.SHOOTER.AT.THE.SCENE", "SHOOTER.S.CAUSE.OF.DEATH", 
                        "POSSIBLE.MOTIVE...GENERAL", "HISTORY.OF.MENTAL.ILLNESS...GENERAL",
                        "NUMBER.OF.SHOTGUNS", "NUMBER.OF.RIFLES", "NUMBER.OF.HANDGUNS", "TOTAL.NUMBER.OF.GUNS",
                        "NUMBER.OF.AUTOMATIC.GUNS", "NUMBER.OF.SEMI.AUTOMATIC.GUNS", 
                        "MILITARY.EXPERIENCE", "CLASS", 
                        "SCHOOL.RELATED", "PLACE.TYPE", "AVERAGE.SHOOTER.AGE", "DATA.SOURCE.1" )]

names(Data1966) <- c("Day", "Date", "CaseID", "Title", "Description", "City", "State", 
                     "VictimsFatal", "VictimsInjured", 
                     "ShooterAge", "ShooterSex", "ShooterRace", "ShooterRelationshipToLocation", 
                     "ShooterFate", "ShooterCOD", "ShooterMotive", "ShooterMentalIllness",
                     "WeaponShotgun", "WeaponRifle", "WeaponHandgun", "WeaponTotal", "WeaponAuto", "WeaponSemiAuto", 
                     "MilitaryExperience", "Class", 
                     "School", "SceneType", "ShooterAvgAge", "Article")

# Cleaning Dates
Data1966$Date <- as.Date(Data1966$Date, format = "%m/%d/%y")
Data1966$Date[1:2] <- sub(20, 19, Data1966$Date[1:2])

# Quantity of Shooters
Data1966$ShooterAge <- as.character(Data1966$ShooterAge)
Data1966 = mutate(Data1966, ShooterQuant = round(nchar(Data1966$ShooterAge) / 3))

# Creating shooter AgeBucket
Data1966 = mutate(Data1966, ShooterAgeBucket = 
                    ifelse(ShooterAvgAge <  18, "<18", 
                           ifelse(ShooterAvgAge <  25, "18-24",
                                  ifelse(ShooterAvgAge <  35, "25-34",
                                         ifelse(ShooterAvgAge <  50, "35-49", "50+")))))

# Standardizing Race
Data1966$ShooterRace[grepl("White", Data1966$ShooterRace)] <- "White American or European American"
Data1966$ShooterRace[grep("Black", Data1966$ShooterRace)] <- "Black American or African American"
Data1966$ShooterRace[grep("Asian", Data1966$ShooterRace)] <- "Asian American"
Data1966$ShooterRace[grep("Some other race", Data1966$ShooterRace)] <- "Unknown"
Data1966$ShooterRace[grep("Two or more races", Data1966$ShooterRace)] <- "Unknown"

# Creating Total Victims = 
Data1966 = mutate(Data1966, VictimsTotal = VictimsFatal + VictimsInjured)

################################################################################################
##### ANALYSIS 1

# Adding census data
TempRace <- group_by_(Data1966,"ShooterRace") %>%
  summarize(., "ShooterTotal" = (n() / nrow(Data1966))*100)
DataRace <- mutate(TempRace, CensusTotal = c(5.4, 13.2, 1.4, 2.6, 77.4))
DataRace <- melt(DataRace, id.vars = "ShooterRace")
names(DataRace) <- c("Race", "variable", "value")


################################################################################################
##### ANALYSIS 2
WeaponDF <- Data1966[,c("Date", "WeaponShotgun", "WeaponRifle", "WeaponHandgun", "WeaponAuto", "WeaponSemiAuto", "WeaponTotal")]
colnames(WeaponDF) <- c("Date", "Shotgun", "Rifle", "Handgun", "Automatic", "SemiAutomatic", "Total")
WeaponDF[,-1] <- lapply(WeaponDF[,-1], function(x) as.numeric(as.character(x)))
WeaponDF[is.na(WeaponDF)] <- 0
TotalWeapons <- sum(WeaponDF[,c(2, 3, 4)])

PercWeapon <- data.frame('Weapon' = c("Rifle", "Handgun", "Shotgun"), 
                         'Percent' = c((sum(WeaponDF$Rifle) / TotalWeapons) * 100, 
                                       (sum(WeaponDF$Handgun) / TotalWeapons) * 100, 
                                       (sum(WeaponDF$Shotgun) / TotalWeapons) * 100)
                         )

# Creating percentage by weapont type - Automatic, Semi-Automatic, Unknown
PercAuto <- (sum(WeaponDF$Automatic) / TotalWeapons) * 100
PercSA <- (sum(WeaponDF$SemiAutomatic) / TotalWeapons) * 100
PercUnk <- 100 - PercAuto - PercSA

# Creating data frame by weapon type
PercWeaponType <- data.frame('Weapon' = c("Automatic", "Semi-Automatic", "Unknown"), 
                         'Percent' = c(PercAuto, PercSA, PercUnk))

################################################################################################
##### ANALYSIS 3
DataUniv <- Data13.15[,c(1, 2 , 3)]
DataUniv$Date <- sapply(DataUniv$Date, as.character)
DataUniv$Date <- as.Date(DataUniv$Date, format = "%m/%d/%Y")
colnames(DataUniv) <- c("Date", "VictimsFatal", "VictimsInjured")
Data1966 <- mutate(Data1966, CityState = paste(City, ", ", State))
DataUniv <- rbind(filter(Data1966[,c("Date", "VictimsFatal", "VictimsInjured")], 
                         Date < "2013-01-01"), DataUniv)
TotalVictims <- sum(DataUniv[,c(2, 3)])
DataUniv <- mutate(DataUniv, Year = substr(DataUniv$Date, 1, 4))
DataUniv <- mutate(DataUniv, Month = substr(DataUniv$Date, 6, 7))
DataYear <- filter(DataUniv, Year > 2012) %>%
  group_by(., Year) %>%
  summarize(., Killed = sum(VictimsFatal), Injured = sum(VictimsInjured))
DataMonth <- group_by(DataUniv, Month) %>%
  summarize(., Killed = sum(VictimsFatal), Injured = sum(VictimsInjured))
DataYear <- melt(DataYear, id.vars = "Year")
DataMonth <- melt(DataMonth, id.vars = "Month")






################################################################################################
##### Needed for Maps Analysis
library(rgdal)
library(sp)
library(taRifx.geo)
library(utils)

# Simple script for geocoding the data from Masshootings website 2013-2015
#   Change dataclass to "character" to be readable by geocode
#   Geocoding data using GGmap and Google
Data2015$Location <- as.character(Data2015$Location) 
Data2015$geo <- geocode(Data2015$Location) 
Data2015g <- Data2015

# Parse GeoCoded Data into longitude (lon) and latitude (lat) columns
#   Remove nested dataframe with geodata
Data2015g$lon <- Data2015g[[6]][[1]]
Data2015g$lat <- Data2015g[[6]][[2]] 
Data2015g <- Data2015g[-6]

# Rinse and repeat above for the following data sets
#   2014   #########################################
Data2014$Location <- as.character(Data2014$Location) 
Data2014$geo <- geocode(Data2014$Location)
Data2014g <- Data2014

Data2014g$lon <- Data2014g[[6]][[1]]
Data2014g$lat <- Data2014g[[6]][[2]]
Data2014g <- Data2014g[-6]

#   2013   #########################################
Data2013$Location <- as.character(Data2013$Location) 
Data2013$geo <- geocode(Data2013$Location)
Data2013g <- Data2013

Data2013g$lon <- Data2013g[[6]][[1]]
Data2013g$lat <- Data2013g[[6]][[2]]
Data2013g <- Data2013g[-6]

#   13.15   #########################################
Data13.15$Location <- as.character(Data13.15$Location)
Data13.15$geo <- geocode(Data13.15$Location)
Data13.15g <- Data13.15

Data13.15g$lon <- Data13.15g[[6]][[1]]
Data13.15g$lat <- Data13.15g[[6]][[2]]
Data13.15g <- Data13.15g[-6]

# Warning messages:
# 1: geocode failed with status ZERO_RESULTS, location = "Ottawa, KA" 
# 2: geocode failed with status ZERO_RESULTS, location = "Witchita, KA" 
# 3: geocode failed with status ZERO_RESULTS, location = "Parsons, KA" 
# 4: geocode failed with status ZERO_RESULTS, location = "Topeka, KA" 

# Save geocoded data to rdata file to be used 
save(Data13.15g, Data2013g, Data2014g, Data2015g, file="App/data/shootingsdata.Rdata")