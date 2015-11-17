library(shiny)
library(leaflet)

# Choices for drop-downs
vars <- c(
  #"2013-2015" = "Data13.15g",
  "2015" = "Data2015g",
  "2014" = "Data2014g",
  "2013" = "Data2013g"
)

vars2 <- c(
  "Number Wounded" = "Wounded",
  "Number Killed" = "Killed"
)

# Resource links to be embedded in appropriate tabs
forum.link    <- "http://www.guncontrolforums.com/"
stanford.link <- 'https://library.stanford.edu/projects/mass-shootings-america'
census.link   <- 'https://www.census.gov/population/projections/data/national/2014.html'

shinyUI(navbarPage("Mass Shootings Data", id="nav",
#########################################################################################################  
#
#   INTERACTIVE MAP TAB PANEL   #########################################################################
#
#########################################################################################################
                   tabPanel('Interactive Map',
                            div(class='outer', 
                                tags$head(
                                  # Include custom CSS
                                  includeCSS('style.css')
                                ),
                                leafletOutput("map", width="100%", height="100%"),
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 120, left = 80, right = "auto", bottom = "auto",
                                              width = "auto", height = "auto", h3("Shootings Plotter"),
                                              selectInput("year", "Select Time Frame", vars),
                                              radioButtons("shot", "Plot Size Will Reflect Count of", vars2, selected = "Wounded"),
                                              helpText(br('Radius corresponds to killed/wounded'),
                                                       br(a('Data: Crowd-sourced data fom shootingtracker',
                                                            href = 'http://shootingtracker.com/wiki/Mass_Shootings_in_2015',
                                                            target = '_blank')),
                                                       br('*2015 data is through October 12, 2015'))
                                )### End of tab panel
                            ) ### End of div
                   ),
#########################################################################################################  
#
#   SHOOTER DATA TAB PANEL      #########################################################################
#
#########################################################################################################
                  tabPanel('Shooter Data',
                           selectInput("Tab1", label = h5("Select shooter profile element:"), 
                                       choices = list("Age" = "ShooterAgeBucket", 
                                                      "Gender" = "ShooterSex",
                                                      "Mental Illness" = "ShooterMentalIllness",
                                                      "Military Experience" = "MilitaryExperience",
                                                      "Race" = "ShooterRace"), 
                                       selected = 1),
                           helpText(a('Click HERE to join the discussion', href = forum.link, target="_blank")),
                           hr(),
                           plotOutput("Plot1"),
                           helpText(br('Use the pull-down menu to select a shooter characteristic for viewing.'),
                                    br(a('Data: Stanford University Mass Shootings of America (MSA) data project',
                                         href = stanford.link,
                                         target = '_blank')),
                                    br(a('Data: 2014 United States Census Data',
                                         href = census.link,
                                         target = '_blank')))
                  ),
#########################################################################################################  
#
#   WEAPON DATA TAB PANEL       #########################################################################
#
#########################################################################################################
                  tabPanel('Weapon Data',
                           selectInput("Tab2", label = h5("Select weapon profile element:"), 
                                       choices = list("Weapon Category" = 1, 
                                                      "Weapon Type" = 2), 
                                       selected = 1),
                           helpText(a('Click HERE to join the discussion', href = forum.link, target="_blank")),
                           hr(),
                           plotOutput("Plot2"),
                           helpText(br('Use the pull-down menu to select a weapon category for viewing.'),
                                    br(a('Data: Stanford University Mass Shootings of America (MSA) data project',
                                         href = stanford.link,
                                         target = '_blank')))
                  ),
#########################################################################################################  
#
#   VICTIM DATA TAB PANEL       #########################################################################
#
#########################################################################################################
                  tabPanel('Killed/Wounded Over Time',
                           selectInput("Tab3", label = h5("Select time scale:"), 
                                       choices = list("Victims Annually" = 1, 
                                                      "Victims Monthly" = 2), 
                                       selected = 1),
                           helpText(a('Click HERE to join the discussion', href = forum.link, target="_blank")),
                           hr(),
                           plotOutput("Plot3"),
                           helpText(br('Use the pull-down menu to select a time period for viewing.'),
                                    br(a('Data: Crowd-sourced data fom shootingtracker',
                                         href = 'http://shootingtracker.com/wiki/Mass_Shootings_in_2015',
                                         target = '_blank')),
                                    br('*2015 data is through October 12, 2015'))
                  ),
                  tabPanel('About', 
                           tags$br('Project Developed for:'), 
                           tags$br('NYC Data Science Academy - Shiny Project'),
                           tags$br('By: Paul Grech and Chris Neimeth')
                  )
                )
)