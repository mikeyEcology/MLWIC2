# shiny
server <- function(input, output, session) {
  
  #- make file selection for some variables
  # base directory for fileChoose
  #volumes =  c(home = "") 
  volumes = shinyFiles::getVolumes()
  # path_prefix
  shinyFiles::shinyDirChoose(input, 'path_prefix', roots=volumes, session=session)
  dirname_path_prefix <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$path_prefix)})
  # Observe path_prefix changes
  shiny::observe({
    if(!is.null(dirname_path_prefix)){
      print(dirname_path_prefix())
      output$path_prefix <- shiny::renderText(dirname_path_prefix())
    }
  })
  # data_info
  shinyFiles::shinyFileChoose(input, "data_info", roots=volumes, session=session, filetypes=c('txt', 'csv'))
  filename_data_info <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$data_info)[length(shinyFiles::parseFilePaths(volumes, input$data_info))]})
  # observeEvent(input$data_info, {
  #   filename <- parseFilePaths(volumes, input$data_info)
  #   output$data_info <- renderText(filename$datapath)
  # })
  # model_dir
  shinyFiles::shinyDirChoose(input, 'model_dir', roots=volumes, session=session)
  dirname_model_dir <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$model_dir)})
  # Observe model_dir changes
  observe({
    if(!is.null(dirname_model_dir)){
      print(dirname_model_dir())
      output$model_dir <- shiny::renderText(dirname_model_dir())
    }
  })
  # python_loc
  shinyFiles::shinyDirChoose(input, 'python_loc', roots=volumes, session=session)
  dirname_python_loc <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$python_loc)})
  # Observe python_loc changes
  shiny::observe({
    if(!is.null(dirname_python_loc)){
      print(dirname_python_loc())
      output$python_loc <- shiny::renderText(dirname_python_loc())
    }
  })
  
  #- run classify
  shiny::observeEvent(input$runSetup_and_classify, {
    setup_and_classify(
      path_prefix = normalizePath(dirname_path_prefix()), 
      recursive=input$recursive,
      data_info = normalizePath(filename_data_info()),
      model_dir = normalizePath(dirname_model_dir()),
      os = input$os,
      already_downloaded_model = input$already_downloaded_model,
      tensorflow_installed = input$tensorflow_installed,
      MLWIC2_already_setup = input$MLWIC2_already_setup,
      save_predictions = input$save_predictions,
      python_loc = normalizePath(dirname_python_loc()),
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
  
}

ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Setup MLWIC2 for your computer and classify images"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    shiny::sidebarPanel(
     shinyFiles::shinyDirButton('python_loc', "Python location", title="Select the location of Python. It should be under Anaconda"),
      shiny::textOutput('python_loc'),
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      shiny::textOutput('path_prefix'),
      shiny::selectInput("recursive", "Are your images stored in sub-folders within this folder? Or are they all directly in this folder?",
                         choices=c(
                           "Stored in sub-folders" = "TRUE",
                           "All images are in this folder" = "FALSE"
                         )),
      shiny::selectInput("os", "Operating system type", choices=c(
        "MacIntosh" = "Mac",
        "Windows"= "Windows",
        "Ubuntu" = "Ubuntu"
      )),
      shiny::selectInput("already_downloaded_model", "Have you already downloaded the trained model?", 
                         choices = c(
                           "No" = "FALSE",
                           "Yes" = "TRUE"
                         )),
     shinyFiles::shinyDirButton('model_dir', 'Trained model directory', title="If you have already downloaded the trained model, select its location. Otherwise, select `cancel`"),
     shiny::textOutput('model_dir'),
      shiny::selectInput("tensorflow_installed", "Have you already installed tensorflow on your machine?",
                         choices = c(
                           "No" = "FALSE",
                           "Yes" = "TRUE"
                         )),
      shiny::selectInput("MLWIC2_already_setup", "Have you already setup your machine to run MLWIC2?",
                         choices = c(
                           "No" = "FALSE",
                           "Yes" = "TRUE"
                         )),
      shiny::selectInput("model_type", "What type of model do you want to use?", 
                         choices = c(
                           "Animal / Empty" = "empty_animal",
                           "Identify animal species" = "species"
                         )),
      
      #shiny::textInput("output_name", "Name of cleaned output file", formals(setup_and_classify)[["output_name"]]),
      shiny::actionButton("runSetup_and_classify", "Setup MLWIC2 and classify images")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server)
