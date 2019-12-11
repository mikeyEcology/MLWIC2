# shiny
server <- function(input, output, session) {
  
  # base directory for fileChoose
  volumes =  c(home = "") #getVolumes()
  #volumes = "/Users/mikeytabak/Desktop/MLWIC_package/MLWIC_examples/"
  shinyDirChoose(input, 'path_prefix', roots=volumes, session=session)
  dirname_path_prefix <- reactive({parseDirPath(volumes, input$path_prefix)})
  #dirname_path_prefix <- reactive({textOutput("path_prefix")})

  ## Observe input dir. changes
  observe({
    if(!is.null(dirname_path_prefix)){
      print(dirname_path_prefix())
      output$path_prefix <- renderText(dirname_path_prefix())
    }
  })
  
  # run classify
  shiny::observeEvent(input$runClassify, {
    classify(#path_prefix = input$path_prefix, 
      #path_prefix = renderText(dirname_path_prefix()),
      path_prefix = dirname_path_prefix(),
             data_info = input$data_info,
             model_dir = input$model_dir,
             save_predictions = input$save_predictions,
             python_loc = input$python_loc,
             num_classes = input$num_classes,
             architecture = input$architecture,
             depth = input$depth,
             top_n = input$top_n,
             batch_size = input$batch_size,
             log_dir= input$log_dir,
      print_cmd=TRUE
    )
  })
  # shiny::observeEvent(input$runClassify, {
  #   make_output(
  #     output_location = input$model_dir,
  #     model_dir= input$model_dir,
  #     saved_predictions = input$save_predictions,
  #     top_n = input$top_n
  #   )
  # })
  
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
      shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      textOutput('path_prefix'),
      #textInput("path_prefix", "Path Prefix"),
      textInput("data_info", "Image Label Location"),
      textInput("model_dir", "Model Directory"),
      textInput("python_loc", "Location of Python on your computer"),
      textInput("num_classes", "Number of classes in trained model (BILD = if using Built In model, you can Leave these categories as Default)", formals(classify)[["num_classes"]]),
      textInput("save_predictions", "Name of text file to save predictions (BILD; must end in .txt)", formals(classify)[["save_predictions"]]) ,
      textInput("log_dir", "Directory name of trained model (BILD)", formals(classify)[["log_dir"]]),
      textInput("architecture", "CNN Architecture (BILD)", formals(classify)[["architecture"]]),
      textInput("depth", "CNN Depth (BILD)", formals(classify)[["depth"]]),
      textInput("top_n", "Number of guesses to save (BILD)", formals(classify)[["top_n"]]),
      textInput("batch_size", "Batch size (BILD)", formals(classify)[["batch_size"]]),
      actionButton("runClassify", "Run Classify Function")
    ), # this works with option 2
  
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
      # Output: Plot of the requested variable against mpg ----
      #h3(textOutput("quant"))
      #h3(renderText(textOutput("quant")))
      #renderPrint("quant")
      #textOutput("value")
      #verbatimTextOutput("folder1", placeholder = TRUE) 
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server)

# put in these vlues
#path prefix: /Users/mikeytabak/Desktop/APHIS/mtMoran_projects/MLWIC_dir/MLWIC_package/MLWIC_examples/MLWIC_examples/images
#image label location: /Users/mikeytabak/Desktop/APHIS/mtMoran_projects/MLWIC_dir/MLWIC_package/MLWIC_examples/MLWIC_examples/image_labels.csv
#model directory: /Users/mikeytabak/Desktop/APHIS/teton_projects/trained_model_20190610/fitted_model/
#python: /anaconda3/bin/
#*** In model.py file, I commented out line 279: self.pretrained_loader.restore(sess, ckpt.model_checkpoint_path)