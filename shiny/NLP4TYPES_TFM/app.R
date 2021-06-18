#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
source("utils/config.R")
source("utils/pipeline.R")

model <- load_model(model_path)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("NLP4TYPES-TFM"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            textInput("new_text", h3("Text input"), value = "Enter text..."),
            actionButton("predict_button", "Predict"),
        ),

        # Show a plot of the generated distribution
        mainPanel(
           textOutput("predicted_label")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    unseen_text <- eventReactive(input$predict_button, {
        input$new_text
    })
    output$predicted_label <- renderText({ 
        main_pipeline(unseen_text(), model)
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
