## app.R ##
library(shiny)
library(shinydashboard)


server <- function(input, output) {
  
  output$wideTable <- renderDataTable({
    table <- KnotData[, input$show_vars, drop = FALSE]
    #table$Websites <- paste0("<a href='",table$Websites,"'>","Link","</a>") 
    
  }, escape = FALSE)
}