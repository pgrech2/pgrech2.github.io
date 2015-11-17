library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(ggplot2)

shinyServer(function(input, output, session) {
  
  # Create the interactive map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%  
      setView(lng = -93.85, lat = 37.45, zoom = 4) 
  })
  
  
  
  # Create the reactive dataframe that will be used for plotting on interactive map
  datapoints <- reactive({
    if(input$year=="Data2013g"){
      return(Data2013g)
    }else if(input$year=="Data2014g"){
        return (Data2014g)
    }else if(input$year=="Data2015g"){
      return (Data2015g)
    }
  })

  
  
  # Use observe function to plot circles based on reactive dataframe from above.
  # Circle radius is based on number of killed/wounded
  # Clicking on event pop-up link to Article for more information
    observe({
      input$year
      if(input$shot == "Wounded"){
        leafletProxy("map", data=datapoints()) %>%
          clearMarkers() %>%
          addCircleMarkers(~lon, ~lat, radius=~Wounded*2,
                     popup = paste0('<p>', 'Date = ', datapoints()$Date, '</p>',
                                    '<p>', 'Wounded = ', datapoints()$Wounded, '</p>', 
                                    '<p>', 'Killed = ', datapoints()$Killed, '</p>',
                                    '<a href=', datapoints()$Article, '>', 'Link', '</a>'))
      }
      if(input$shot == "Killed"){
        leafletProxy("map", data=datapoints()) %>%
          clearMarkers() %>%
          addCircleMarkers(~lon, ~lat, radius=~Killed*2,
                           popup =  paste0('<p>', 'Date = ', datapoints()$Date, '</p>',
                                           '<p>', 'Wounded = ', datapoints()$Wounded, '</p>', 
                                           '<p>', 'Killed = ', datapoints()$Killed, '</p>',
                                           '<a href=', datapoints()$Article, '>', 'Link', '</a>'))
        
      }
    }) ### End of observe
    
    
    
    
    
    ##### CREATING TAB 1 DATA FRAME
    Tab1DF <- reactive({
      if(input$Tab1 == "ShooterRace"){
        DataRace
      }
      else{
      group_by_(Data1966,input$Tab1) %>%
        summarize(., "Total" = (n() / nrow(Data1966)) * 100)
      }
    })
    
    ##### Creating Tab1 Plot 
    output$Plot1 <- renderPlot({
      if(input$Tab1 == "ShooterAgeBucket"){
        glab <- "Age Bucket"}
      else if(input$Tab1 == "ShooterSex"){
        glab <- "Gender"}
      else if(input$Tab1 == "ShooterMentalIllness"){
        glab <- "Mental Health"}
      else if(input$Tab1 == "MilitaryExperience"){
        glab <- "Military Experience"}
      else if(input$Tab1 == "ShooterRace"){
        glab <- "Race"
      }
      
      if(input$Tab1 == "ShooterRace"){
        ggplot(Tab1DF(), aes_string(x = "Race", y = "value", fill = "variable")) + 
          geom_bar(position = "dodge", stat = "identity") +
          scale_fill_brewer() +
          ggtitle(paste("Percentage of Shootings and Population By", glab)) +
          xlab(glab) + 
          ylab("Percentage") + 
          theme_bw() + 
          theme(axis.text.x = element_text(angle=45, hjust=1))
      } else{
        ggplot(Tab1DF(), 
               aes_string(x = input$Tab1, y = "Total", fill = input$Tab1)) + 
          geom_bar(stat = "identity") + 
          scale_fill_brewer() +
          ggtitle(paste("Percentage of Shootings By", glab)) +
          xlab(glab) + 
          ylab("Percentage of Total Shootings") + 
          theme_bw() + 
          theme(axis.text.x = element_text(angle=45, hjust=1))
      }
      
    })
    
    
    ##### CREATING TAB2 DATA FRAME
    Tab2DF <- reactive({
      if(input$Tab2 == 1){
        PercWeapon
      } else if(input$Tab2 == 2){
        PercWeaponType
      }
    })
    
    ##### Creating Tab2 Plot
    output$Plot2 <- renderPlot({
      if(input$Tab2 == 1){
        gtitle <- "Weapon Category"}
      else if(input$Tab2 == 2){
        gtitle <- "Weapon Type"}
      
      ggplot(Tab2DF(), aes_string(x = "Weapon", y = "Percent", fill = "Weapon")) + 
        geom_bar(stat = "identity") + 
        scale_fill_brewer() +
        ggtitle(paste("Percentage of Shootings By", gtitle)) +
        xlab(gtitle) + 
        ylab("Percentage of Total Shootings") + 
        theme_bw()
    })
    
    
    ##### CREATING TAB3 DATA FRAME
    Tab3DF <- reactive({
      if(input$Tab3 == 1){
        DataYear
      } else if(input$Tab3 == 2){
        DataMonth
      }
    })
    
    ##### Creating Tab3 plot
    output$Plot3 <- renderPlot({
      if(input$Tab3 == 1){
        gtitle <- "Year"}
      else if(input$Tab3 == 2){
        gtitle <- "Month"}
      
      ggplot(Tab3DF(), aes_string(x = gtitle, y = "value", fill = "variable")) + 
        geom_bar(position = "dodge", stat = "identity") +
        scale_fill_brewer() +
        ggtitle(paste("Victims By", gtitle)) +
        xlab(gtitle) + 
        ylab("Victims") + 
        theme_bw()
    })
})
 
 