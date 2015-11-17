# Paul Grech
# Project 1 - Fuel Economy Data Set
# ?package::____
# theme -> axis.ticks.x

# ASSUMPTIONS:
#   EV, Hybrid, Drive type, Transmission
#     The breakdown of a manufacturers fleet is not what is analyzed.
#     Performance by each company at the company level is what will be critiqued.
#   Market demand drives sales evenly across all combinations of Class/Trans/DT

library(lsr)
library(dplyr)
library(ggplot2)

# Import Data and convert to Dplyr data frame
#FuelData <- load("Project1.Data/FuelEconomyGov.csv", stringsAsFactors = FALSE)
#FuelData <- tbl_df(FuelData)
load("data/fueleconomy.RData")

# Important Variables:
#   mfrCode     3-character manufacturer code
#   year        Model year
#   make        Manufacturer (division)
#   model       Model name (carline)
#   engId       EPA model type index
#   eng_dscr    Engine descriptor
#                 http://www.fueleconomy.gov/feg/findacarhelp.shtml#engine
#   cylinders   Engine cylinders
#   displ       Engine displacement in liters
#   sCharger    If S, this vehicle is supercharged
#   tCharger    If T, this vehicle is turbocharged
#   startStop   Vehicle has start-stop technology (Y, N, or blank for older vehicles)
#   phevBlended If true,  vehicle operates on blend of gasoline and electricity in charge depleting mode
#   trans_dscr  Transmission descriptor
#                 see http://www.fueleconomy.gov/feg/findacarhelp.shtml#trany
#   trany       Transmission
#   drive       Drive axle type
#   city08u     City MPG for fueltype1 unrounded
#   comb08u     Combined MPG for fueltype1 unrounded
#   highway08U  Unrounded highway MPG for fuelType1

# Create data frame including information necessary for analysis
FuelDataV1 <- select(FuelData,
  mfrCode, year, make, model,
  engId, eng_dscr, cylinders, displ, sCharger, tCharger,
  trans_dscr, trany, drive,
  startStop, phevBlended,
  city08, comb08, highway08,
  VClass)

# Explore data
names(FuelDataV1)
head(FuelDataV1)
tail(FuelDataV1)

# Replace Zero values in MPG data with NA
FuelDataV1$city08U[FuelDataV1$city08 == 0] <- NA
FuelDataV1$comb08U[FuelDataV1$comb08 == 0] <- NA
FuelDataV1$highway08U[FuelDataV1$highway08 == 0] <- NA

######################################################################################################
# COMPARE INDUSTRY EPA RATINGS FOR CITY AND HIGHWAY WITH THAT OF CADILLAC
IndCityMPG <- group_by(FuelDataV1, year) %>%
  summarise(., MPG = mean(city08, na.rm = TRUE)) %>%
  mutate(., Label = "Industry") %>%
  mutate(., MPGType = "City")
IndHwyMPG <-  group_by(FuelDataV1, year) %>%
  summarise(., MPG = mean(highway08, na.rm = TRUE)) %>%
  mutate(., Label = "Industry") %>%
  mutate(., MPGType = "Highway")
CadCityMPG <- filter(FuelDataV1, make == "Cadillac") %>%
  group_by(., year) %>%
  summarize(., MPG = mean(city08, na.rm = TRUE)) %>%
  mutate(., Label = "Cadillac") %>%
  mutate(., MPGType = "City")
CadHwyMPG <-  filter(FuelDataV1, make == "Cadillac") %>%
  group_by(., year) %>%
  summarize(., MPG = mean(highway08, na.rm = TRUE)) %>%
  mutate(., Label = "Cadillac") %>%
  mutate(., MPGType = "Highway")

Comp.Ind.Cad <- rbind(IndCityMPG, IndHwyMPG, CadCityMPG, CadHwyMPG)

ggplot(data = Comp.Ind.Cad, aes(x = year, y = MPG, color = Label, linetype = MPGType)) + 
  geom_point() + geom_line() + theme_bw() + 
  scale_color_manual(name = "Cadillac / Industry", values = c("blue","#666666")) +
  ggtitle("Cadillac v.s. Industry\n(city & highway MPG)")



######################################################################################################
# WHO ARE CADILLACS PRIMARY COMPETITORS?
#   Primary competition - German Luxury Market
#   Cad vs Germ fleet fuel economy

# Calculate Cadillac average Highway / City MPG past 2000
CadCityMPG <- filter(CadCityMPG, year > 2000)
CadHwyMPG <-  filter(CadHwyMPG, year > 2000)

# Calculate Audi average Highway / City MPG
AudCityMPG <- filter(FuelDataV1, make == "Audi", year > 2000) %>%
  group_by(., year) %>%
  summarize(., MPG = mean(city08, na.rm = TRUE)) %>%
  mutate(., Label = "Audi") %>%
  mutate(., MPGType = "City")
AudHwyMPG <-  filter(FuelDataV1, make == "Audi", year > 2000) %>%
  group_by(., year) %>%
  summarize(., MPG = mean(highway08, na.rm = TRUE)) %>%
  mutate(., Label = "Audi") %>%
  mutate(., MPGType = "Highway")

# Calculate BMW average Highway / City MPG
BMWCityMPG <- filter(FuelDataV1, make == "BMW", year > 2000) %>%
  group_by(., year) %>%
  summarize(., MPG = mean(city08, na.rm = TRUE)) %>%
  mutate(., Label = "BMW") %>%
  mutate(., MPGType = "City")
BMWHwyMPG <-  filter(FuelDataV1, make == "BMW", year > 2000) %>%
  group_by(., year) %>%
  summarize(., MPG = mean(highway08, na.rm = TRUE)) %>%
  mutate(., Label = "BMW") %>%
  mutate(., MPGType = "Highway")

# Calculate Mercedes-Benz average Highway / City MPG
MbzCityMPG <- filter(FuelDataV1, make == "Mercedes-Benz", year > 2000) %>%
  group_by(., year) %>%
  summarize(., MPG = mean(city08, na.rm = TRUE)) %>%
  mutate(., Label = "Merc-Benz") %>%
  mutate(., MPGType = "City")
MbzHwyMPG <-  filter(FuelDataV1, make == "Mercedes-Benz", year > 2000) %>%
  group_by(., year) %>%
  summarize(., MPG = mean(highway08, na.rm = TRUE)) %>%
  mutate(., Label = "Merc-Benz") %>%
  mutate(., MPGType = "Highway")

# Concatenate all Highway/City MPG data for:
#     v.s. German Competitors
CompGerCadCity <- rbind(CadCityMPG, AudCityMPG, BMWCityMPG, MbzCityMPG)
CompGerCadHwy <- rbind(CadHwyMPG, AudHwyMPG, BMWHwyMPG, MbzHwyMPG)

# Plot all Highway/City MPG data for:
#     v.s. German Competitors

ggplot(data = CompGerCadCity, aes(x = year, y = MPG, color = Label)) + 
  geom_line() + geom_point() + theme_bw() + 
  scale_color_manual(name = "Cadillac vs German Luxury Market", 
                     values = c("#333333", "#666666", "blue","#999999")) +
  ggtitle("CITY MPG\n(Cad vs Audi vs BMW vs Mercedes-Benz)")

ggplot(data = CompGerCadHwy, aes(x = year, y = MPG, color = Label)) + 
  geom_line() + geom_point() + theme_bw() + 
  scale_color_manual(name = "Cadillac vs German Luxury Market", 
                     values = c("#333333", "#666666", "blue","#999999")) +
  ggtitle(label = "HIGHWAY MPG\n(Cad vs Audi vs BMW vs Mercedes-Benz)")




######################################################################################################
# Break down industry averages according to vehicle type
# Make.By.Class <- summarize(group_by(FuelDataV1, VClass, make), Quantity = n())

German <- filter(FuelDataV1, make %in% c("Cadillac", "Audi", "BMW", "Mercedes-Benz"))
German$VClass.new <- ifelse(grepl("Compact", German$VClass, ignore.case = T), "Compact", 
                          ifelse(grepl("Wagons", German$VClass), "Wagons", 
                                 ifelse(grepl("Utility", German$VClass), "SUV", 
                                        ifelse(grepl("Special", German$VClass), "SpecUV", German$VClass))))
# Verify vehicle class has been changed
unique(German$VClass.new)
# Focus on vehicle model years past 2000
German <- filter(German, year > 2000)
# Vans, Passenger Type are only specific to one company and are not needed for this analysis
German <- filter(German, VClass.new != "Vans, Passenger Type")



# INDUSTRY
IndClass <- filter(German, make %in% c("Audi", "BMW", "Mercedes-Benz")) %>%
  group_by(VClass.new, year) %>%
  summarize(AvgCity = mean(city08), AvgHwy = mean(highway08))
# CADILLAC
CadClass <- filter(German, make %in% c("Cadillac")) %>%
  group_by(VClass.new, year) %>%
  summarize(AvgCity = mean(city08), AvgHwy = mean(highway08))


## CUSTOMIZING GRAPHICS - SLIDE 118 AND 119 ##
##### CADILLAC AND AUDI #####
CadIndClass <- left_join(IndClass, CadClass, by = c("year", "VClass.new"))
CadIndClass$DifCity <- (CadIndClass$AvgCity.y - CadIndClass$AvgCity.x)
CadIndClass$DifHwy <- (CadIndClass$AvgHwy.y - CadIndClass$AvgHwy.x)

ggplot(CadIndClass, aes(x = year, ymax = DifCity, ymin = 0) ) + 
  geom_linerange(color='grey20', size=0.5) + 
  geom_point(aes(y=DifCity), color = 'blue') +
  geom_hline(yintercept = 0) +
  theme_bw() + 
  facet_wrap(~VClass.new) +
  ggtitle("Cadillac v.s. Germany Luxury Market\n(city MPG by class)") +
  xlab("Year") + 
  ylab("MPG Difference")
ggplot(CadIndClass, aes(x = year, ymax = DifHwy, ymin = 0) ) + 
  geom_linerange(color='grey20', size=0.5) + 
  geom_point(aes(y=DifHwy), color='blue') +
  geom_hline(yintercept = 0) +
  theme_bw() + 
  facet_wrap(~VClass.new) +
  ggtitle("Cadillac v.s. German Luxury Market\n(highway MPG by class)") +
  xlab("Year") + 
  ylab("MPG Difference")
