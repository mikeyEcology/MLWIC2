# shiny
server <- function(input, output, session) {
  
  #- make file selection for some variables
  # base directory for fileChoose
  volumes =  c(home = "") #%%% Erica: You might have to comment out this line and run the next one instead
  #volumes = getVolumes()
  # path_prefix
  shinyDirChoose(input, 'path_prefix', roots=volumes, session=session)
  dirname_path_prefix <- reactive({parseDirPath(volumes, input$path_prefix)})
  # Observe path_prefix changes
  observe({
    if(!is.null(dirname_path_prefix)){
      print(dirname_path_prefix())
      output$path_prefix <- renderText(dirname_path_prefix())
    }
  })
  # data_info
  shinyFileChoose(input, "data_info", roots=volumes, session=session, filetypes=c('txt', 'csv'))
  filename_data_info <- reactive({parseFilePaths(volumes, input$data_info)[length(parseFilePaths(volumes, input$data_info))]})
  # observeEvent(input$data_info, {
  #   filename <- parseFilePaths(volumes, input$data_info)
  #   output$data_info <- renderText(filename$datapath)
  # })
  # model_dir
  shinyDirChoose(input, 'model_dir', roots=volumes, session=session)
  dirname_model_dir <- reactive({parseDirPath(volumes, input$model_dir)})
  # Observe model_dir changes
  observe({
    if(!is.null(dirname_model_dir)){
      print(dirname_model_dir())
      output$model_dir <- renderText(dirname_model_dir())
    }
  })
  # python_loc
  shinyDirChoose(input, 'python_loc', roots=volumes, session=session)
  dirname_python_loc <- reactive({parseDirPath(volumes, input$python_loc)})
  # Observe python_loc changes
  observe({
    if(!is.null(dirname_python_loc)){
      print(dirname_python_loc())
      output$python_loc <- renderText(dirname_python_loc())
    }
  })

  #- run classify
  shiny::observeEvent(input$runClassify, {
    classify(#path_prefix = input$path_prefix,
      #path_prefix = renderText(dirname_path_prefix()),
      path_prefix = dirname_path_prefix(),
             #data_info = input$data_info,
      data_info = filename_data_info(),
             #model_dir = input$model_dir,
      model_dir = dirname_model_dir(),
             save_predictions = input$save_predictions,
             #python_loc = input$python_loc,
      python_loc = dirname_python_loc(),
             num_classes = input$num_classes,
             architecture = input$architecture,
             depth = input$depth,
             top_n = input$top_n,
             batch_size = input$batch_size,
             log_dir= input$log_dir,
      shiny=TRUE,
      make_output=TRUE,
      output_name=input$output_name,
      print_cmd=FALSE
    )
  })
  # shiny::observeEvent(input$runClassify, {
  #   make_output(
  #     output_location = input$model_dir,
  #     model_dir= input$model_dir,
  #     saved_predictions = input$save_predictions,
  #     top_n = input$top_n,
  #     shiny=TRUE
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
      #textInput("data_info", "Image Label Location"),
      shinyFilesButton('data_info', "Image label file", title="Select file containing file names of images and their classification", multiple=FALSE),
      textOutput("data_info"),
      #textInput("model_dir", "Model Directory"),
      shinyDirButton('model_dir', 'Trained model directory', title="Select the location where you stored the 'trained_model' folder"),
      textOutput('model_dir'),
      #textInput("python_loc", "Location of Python on your computer"),
      shinyDirButton('python_loc', "Python location", title="Select the location of Python. It should be under Anaconda"),
      textOutput('python_loc'),
      textInput("num_classes", "Number of classes in trained model (BILD = if using Built In model, you can Leave these categories as Default)", formals(classify)[["num_classes"]]),
      textInput("save_predictions", "Name of text file to save predictions (BILD; must end in .txt)", formals(classify)[["save_predictions"]]) ,
      textInput("log_dir", "Directory name of trained model (BILD)", formals(classify)[["log_dir"]]),
      textInput("architecture", "CNN Architecture (BILD)", formals(classify)[["architecture"]]),
      textInput("depth", "CNN Depth (BILD)", formals(classify)[["depth"]]),
      textInput("top_n", "Number of guesses to save (BILD)", formals(classify)[["top_n"]]),
      textInput("batch_size", "Batch size (BILD)", formals(classify)[["batch_size"]]),
      textInput("output_name", "Name of cleaned output file", formals(classify)[["output_name"]]),
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