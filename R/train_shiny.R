server <- function(input, output, session) {
  
  #- make file selection for some variables
  # base directory for fileChoose
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
  
  #- run train
  shiny::observeEvent(input$runTrain, {
    train(#path_prefix = input$path_prefix,
      #path_prefix = renderText(dirname_path_prefix()),
      path_prefix = normalizePath(dirname_path_prefix()), #%%% I think I need to put normalizePath() on these
      #data_info = input$data_info,
      data_info = normalizePath(filename_data_info()),
      #model_dir = input$model_dir,
      model_dir = normalizePath(dirname_model_dir()),
      #python_loc = input$python_loc,
      python_loc = normalizePath(dirname_python_loc()),
      num_classes = input$num_classes,
      architecture = input$architecture,
      depth = input$depth,
      batch_size = input$batch_size,
      log_dir_train= input$log_dir_train,
      os = input$os,
      num_gpus = input$num_gpus,
      retrain = input$retrain,
      retrain_from = input$retrain_from,
      num_epochs = input$num_epochs,
      max_to_keep = input$max_to_keep,
      randomize = input$randomize,
      shiny=TRUE,
      print_cmd=FALSE
    )
  })
  
}

# Define UI for miles per gallon app ----
ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Train a machine learning model to recognize animals"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      shiny::textOutput('path_prefix'),
      shinyFiles::shinyFilesButton('data_info', "Image label file", title="Select file containing file names of images and their classification", multiple=FALSE),
      shiny::textOutput("data_info"),
      shinyFiles::shinyDirButton('model_dir', 'Trained model directory', title="Select the location where you stored the 'trained_model' folder"),
      shiny::textOutput('model_dir'),
      shinyFiles::shinyDirButton('python_loc', "Python location", title="Select the location of Python. It should be under Anaconda"),
      shiny::textOutput('python_loc'),
      shiny::textInput("num_classes", "Number of classes in trained model (If you are using the built in model, leave all remaining windows with the default option)", formals(train)[["num_classes"]]),
      shiny::textInput("log_dir_train", "Directory name of trained model", formals(train)[["log_dir_train"]]),
      shiny::textInput("architecture", "CNN Architecture", formals(train)[["architecture"]]),
      shiny::textInput("depth", "CNN Depth", formals(train)[["depth"]]),
      shiny::textInput("batch_size", "Batch size", formals(train)[["batch_size"]]),
      shiny::selectInput("os", "Operating system type", choices=c(
        "MacIntosh" = "Mac",
        "Windows"= "Windows",
        "Ubuntu" = "Ubuntu"
      )),
      shiny::textInput("num_gpus", "Number of GPUs to use", formals(train)[["num_gpus"]]),
      shiny::selectInput("retrain", "Are you retraining a model?", choices=c(
        "Yes" = "TRUE",
        "No" = "FALSE"
      )),
      shiny::textInput("retrain_from", "Name of model you are retraining from", formals(train)[["retrain_from"]]),
      shiny::textInput("num_epochs", "Number of epochs to use for training", formals(train)[["num_epochs"]]),
      shiny::textInput("max_to_keep", "Maximum number of checkpoints to save", formals(train)[["max_to_keep"]]),
      shiny::selectInput("randomize", "Do you want to randomize the order of images for training", c(
        "Yes" = "TRUE",
        "No" = "FALSE"
      )),
      shiny::actionButton("runTrain", "Train model")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server)
