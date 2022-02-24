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

model_en <- load_model(model_path_en)
model_es <- load_model(model_path_es)

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel(h1("NLP4TYPES-TFM", align = "center")),
    br(),
    h5("This application classifies an input text in to one of the classes from the DBpedia ontology. 
       The input text should describe any kind of entity (e.g. Person, Place, Artist, etc.) with a 
       length between 5 and 50000 characters.", align = "center", style = "color: grey"),
    br(),
    sidebarLayout(
        sidebarPanel(
            #h3("Description text:"),
            textAreaInput(inputId = "new_text",label=h4("Description text:"), placeholder = 'Enter input text...',
                          value=test_text, width= "1000px", height = "150px"),
            radioButtons("language_selector", label = h6("Select language:"),
                         choices = list("English" = 1, "Spanish" = 2), 
                         selected = 1, inline= TRUE),
            actionButton("predict_button", "Predict type", class = "btn-block", style = "background-color:#FFFFFF;
                      color:#000000;
                      border-color:#44BCEB;
                      border-style:double;
                      border-width:1px;
                      font-size:16px;"),
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            
            h4("Described text is classified as:"),
            h4(textOutput("predicted_label")),
            uiOutput("predicted_URI")
            
            #span(a(textOutput("verb"),'sss¨'),style="font-size:10px")
        ),
    ),
    
    hr(),
    
    tags$footer(HTML("
                    <!-- Footer -->
                           <footer class='page-footer font-large indigo'>
                           <p align='center', style='color:grey'>This work is part of a final master work of the <a href='http://dia.fi.upm.es/mastercd'>MSC in data science</a> of the Universidad Politecnica de Madrid.</p>
                           <!-- Copyright -->
                           <div class='footer-copyright text-center py-3'>
                           <a href='https://oeg.fi.upm.es/'> © 2021 Ontology Engineering Group </a>
                           </div>
                           <!-- Copyright -->
                           <div class='footer-copyright text-center py-3'>
                           <a href='https://github.com/Fcabla/NLP4TYPES-TFM'> Github </a>
                           <a href='https://www.linkedin.com/in/fernando-casab%C3%A1n-blasco-261b4a183/'> LinkedIn </a>
                           </div>
                           </footer>
                           <!-- Footer -->"))
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    unseen_text <- eventReactive(input$predict_button, {
        input$new_text
    })
    
    language_s <- eventReactive(input$predict_button, {
        input$language_selector
    })
    output$predicted_label <- renderText({ 
        if(language_s()==1){
            main_pipeline(unseen_text(), model_en)
        }else{
            main_pipeline(unseen_text(), model_es)
        }
        #main_pipeline(unseen_text(), model, language)
        #paste(ent_type, '<br>', '<http://dbpedia.org/ontology/',ent_type,'>')
    })
    
    output$predicted_URI <- renderUI(
        
        if(language_s()==1){
            #paste('http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model_en), sep='')
            a(paste('<http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model_en),'>', sep=''),
              href = paste('http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model_en), sep=''))
            #tagList(paste('<',paste('http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model_en), sep=''),'>',sep=''),
                    #paste('http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model_en), sep=''))
        }else{
            #tagList(paste('<',paste('http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model_es), sep=''),'>',sep=''),
                    #paste('http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model_es), sep=''))
            a(paste('<http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model_es),'>', sep=''),
              href = paste('http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model_es), sep=''))
            #paste('http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model_es), sep='')
        }
        #paste('<http://dbpedia.org/ontology/',main_pipeline(unseen_text(), model),'>', sep='')
        #paste(ent_type, '<br>', '<http://dbpedia.org/ontology/',ent_type,'>')
    )
    
}

# Run the application 
shinyApp(ui = ui, server = server)
