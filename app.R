library(shiny)
library(ggplot2)
library(dplyr)
library(readr)
df <- read_delim("UAH-lower-troposphere-long.csv.bz2")

# Define UI for application 
ui <- tabsetPanel(
  type = "tabs",
  tabPanel("DataSet", uiOutput("p1")),
  tabPanel("Plot", uiOutput("p2")),
  tabPanel("Table", uiOutput("p3"))
)

# Define server logic required for application

server <- function(input, output) {

  # Data in UAH-lower-troposphere-long.csv
  # year month region temp

  # =================================
  # Page 1
  # =================================
  output$p1 <- renderUI({
    fluidPage(
      titlePanel("Global Temperature Data"),
      mainPanel(
        p("This dataset contains monthly temperature anomalies from the UAH lower troposphere dataset."),
        p("The data has ",
          strong("year, month, region,"),
          em("and"), 
          strong("temp.")
        ),
        tableOutput("sample")
      ),
    )
  })
  
  output$sample <- renderTable({
    df[sample(nrow(df), size=5), ]
  })
  
  # =================================
  # Page 2
  # =================================
  output$p2 <- renderUI({
    fluidPage(
      titlePanel("Plot"),
      sidebarLayout(
        sidebarPanel(
          p("The plot analyzes mean temps given the region.",
            "The plot is on the right and depends on the chosen region."),
          
          # Hide Trend Lines
          checkboxInput(
            inputId = "checkbox",
            label = "Hide Trend Lines",
            value = FALSE
          ),
          
          sliderInput(
            inputId = "years",
            label = "Years:",
            min = min(unique(df$year)),
            max = max(unique(df$year)),
            value = c(min(unique(df$year)), max(unique(df$year)))
          ),
          
          # Choose Regions to display
          checkboxGroupInput(
            inputId = "region",
            label = "Region",
            choices = c(unique(df$region)),
            selected = c("globe", "globe_land", "globe_ocean")
          ),
          
        ),
        
        mainPanel(
          plotOutput("plot"),
          textOutput("text1"),
        )
      )
    )
  })
  
  output$text1 <- renderText({
    ## The average difference in temperature from YYYY to YYYY is ####
    res <- df1() %>% 
      filter(!is.na(year), !is.na(temp), year %in% input$years) %>% 
      group_by(year) %>% 
      summarize(avg_temp = mean(temp)) %>% 
      summarize(diff = last(avg_temp) - first(avg_temp)) %>% 
      pull(diff)
    
    paste("The average difference in temperature from", input$years[1], "to", input$years[2], "is", res)
    
  })
  
  df1 <- reactive({
    df %>%
      filter(region %in% input$region,
             # slider input by years
             year >= input$years[1], 
             year <= input$years[2])
  })
  
  output$plot <- renderPlot({
    p1 <- df1() %>%
      filter(!is.na(year)) %>%
      group_by(region, year) %>%
      summarize(`Mean Temp` = mean(temp)) %>%
      ggplot(aes(x = year,
                 y = `Mean Temp`,
                 col = region)) +
      geom_point() + 
      labs(x = paste("Year ", "(", input$years[1], " to ", input$years[2], ")", sep = ""),
           y = "Mean Temp", 
           title = "Mean Temp per Year (by Region)") 
    
    # Add/hide Trend Line logic
    if (input$checkbox) p1 # Hide TL
    else p1 + geom_smooth() # Add TL
  })
  
  
  # =================================
  # Page 3
  # =================================
  output$p3 <- renderUI({
      fluidPage(
        titlePanel("Table"),
        sidebarLayout(
          sidebarPanel(
            p("This table contains monthly temperature anomalies from the UAH lower troposphere dataset."),
            p("A range of years can be selected below."),
            sliderInput(
              inputId = "yearsTable",
              label = "Select Year(s):",
              min = min(unique(df$year)),
              max = max(unique(df$year)),
              value = c(min(unique(df$year)), max(unique(df$year)))
            ),
            p("The months are represented by their numerical identifier below."),
            checkboxGroupInput(
              inputId = "month",
              label = "Select Month(s)",
              choices = c(unique(df$month)),
              selected = c(1, 12)
            ),
            p("The columns are ",
              strong("year, month, region,"),
              "and",
              strong("temp."),
              br(),
              "You can select columns you want to show below."
            ),
            checkboxGroupInput(
              inputId = "cols",
              label = "Columns",
              choices = colnames(df),
              selected = colnames(df)
            ),
          ),
          mainPanel(
            h2("Table of Temperatures"),
            textOutput("text2"),
            textOutput("text3"),
            tableOutput("tables")
          ),
        )
      )
  })
  
  output$text2 <- renderText({
    paste("Amount of Rows (n):", nrow(df2()))
  })
  output$text3 <- renderText({
    paste("Average Temp of Displayed Data (Fahreinheit):", mean(df2()$temp))
  })
  
  output$tables <- renderTable({
    temp_df <- df2() %>% 
      summarize(year, month, region, temp)
    temp_df[, input$cols]
  })
  
  # Reactive for years 
  df2 <- reactive({
    df %>%
      filter(year >= input$yearsTable[1], 
             year <= input$yearsTable[2],
             month %in% input$month)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

