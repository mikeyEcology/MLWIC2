# shiny
library(shiny)
server <- function(input, output) {
  
  # run classify
  shiny::observeEvent(input$runClassify, {
    classify(path_prefix = input$path_prefix,
              data_info = input$data_info,
              model_dir = input$model_dir,
             save_predictions = input$save_predictions,
             python_loc = input$python_loc,
             num_classes = input$num_classes,
             architecture = input$architecture,
             depth = input$depth,
             top_n = input$top_n,
             batch_size = input$batch_size,
             log_dir= input$log_dir
             )
  })
  shiny::observeEvent(input$runClassify, {
    make_output(
      output_location = input$model_dir,
      model_dir= input$model_dir,
      saved_predictions = input$save_predictions,
      top_n = input$top_n
    )
  })
  
  # observeEvent(input$runClassify, {
  #   wd <- getwd()
  #   output$value <- renderPrint(wd)
  # })
}
# Define UI for miles per gallon app ----
ui <- fluidPage(
  
  # App title ----
  shiny::titlePanel("Classify images using MLWIC2"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    # Sidebar panel for inputs ----
    # sidebarPanel(
    #   selectInput("breaks", "Breaks:",
    #               seq(0.01, .99, by=0.01))
    # ), # this works with option 1
    
    shiny::sidebarPanel(
      textInput("path_prefix", "Path Prefix"),
      textInput("data_info", "Image Label Location"),
      textInput("model_dir", "Model Directory"),
      textInput("python_loc", "Location of Python on your computer"),
      textInput("num_classes", "Number of classes in trained model (BILB = If using built in model, you can leave these categories blank)"),
      textInput("save_predictions", "Name of text file to save predictions (BILB; must end in .txt)"),
      textInput("log_dir", "Directory name of trained model (BILB)"),
      textInput("architecture", "CNN Architecture (BILB)"),
      textInput("depth", "CNN Depth (BILB)"),
      textInput("top_n", "Number of guesses to save (BILB)"),
      textInput("batch_size", "Batch size (BILB)"),
      actionButton("runClassify", "Run Classify Function")
    ), # this works with option 2
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
      # Output: Plot of the requested variable against mpg ----
      #h3(textOutput("quant"))
      #h3(renderText(textOutput("quant")))
      #renderPrint("quant")
      #textOutput("value")
      
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server)

# put in these vlues
#path prefix: /Users/mikeytabak/Desktop/APHIS/mtMoran_projects/MLWIC_dir/MLWIC_package/MLWIC_examples/MLWIC_examples/images
#image label location: /Users/mikeytabak/Desktop/APHIS/mtMoran_projects/MLWIC_dir/MLWIC_package/MLWIC_examples/MLWIC_examples/image_labels.csv
#model directory: /Users/mikeytabak/Desktop/APHIS/teton_projects/trained_model_20190610/fitted_model/
  #*** In model.py file, I commented out line 279: self.pretrained_loader.restore(sess, ckpt.model_checkpoint_path)