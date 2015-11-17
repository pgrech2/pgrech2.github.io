## ui.R ##
library(shinydashboard)


header <- dashboardHeader(title="Wedding Scrape")

sidebar <-  dashboardSidebar(
  sidebarMenu(
    menuItem("The Knot", 
             tabName="first"
    )
  )
)

body <- dashboardBody(
  tabItems(                   
    tabItem(tabName="first",
            h2("The Knot"),
            fluidRow( dataTableOutput('wideTable')
                      ),
            checkboxGroupInput('show_vars', 
                               'Select Data:', 
                               names(KnotData),
                               selected = names(KnotData)
                               )
            )
    )
)


ui<-dashboardPage(skin = 'black',
  header,
  sidebar,
  body
)