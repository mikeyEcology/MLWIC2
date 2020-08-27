server <- function(input, output, session) {
  
  # determine if Windows and create appropriate slashes
  if(Sys.info()["sysname"] == "Windows"){
    Windows <- TRUE
  } else {
    Windows <- FALSE
  }
  os = ifelse(Windows, "Windows", "Mac")
  
  #- make file selection for some variables
  # base directory for fileChoose
  volumes = shinyFiles::getVolumes()
  # path_prefix
  shinyFiles::shinyDirChoose(input, 'path_prefix', roots=volumes(), session=session)
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
  shinyFiles::shinyDirChoose(input, 'model_dir', roots=volumes(), session=session)
  dirname_model_dir <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$model_dir)})
  # Observe model_dir changes
  observe({
    if(!is.null(dirname_model_dir)){
      print(dirname_model_dir())
      output$model_dir <- shiny::renderText(dirname_model_dir())
    }
  })
  # python_loc
  shinyFiles::shinyDirChoose(input, 'python_loc', roots=volumes(), session=session)
  dirname_python_loc <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$python_loc)})
  # Observe python_loc changes
  shiny::observe({
    if(!is.null(dirname_python_loc)){
      print(dirname_python_loc())
      output$python_loc <- shiny::renderText(dirname_python_loc())
    }
  })
  
  # print output for running function as one element
  output$print <- renderText({
    inFile <- input$data_info
    if(is.integer(inFile)){
      return("This printout will appear once you select your input file.")
    } else{
      # on Windows deal with  issuefinding the right drive
      if(os == "Windows"){
        root <- inFile$root
        root1 <- gsub("\\(", "", root)
        root2 <- gsub("\\)", "", root1) # this gives [Drive]:
        data_info_collapse <- paste0(root2, paste0(inFile$files$`0`, collapse="/"))
      } else { # on not windows, we don't have to deal with this
        data_info_collapse <- paste0(inFile$files$`0`, collapse="/")
      }
    }
    gsub("\\\\", "/", paste0("train(\n
                             path_prefix = '", normalizePath(dirname_path_prefix()), "',",
                             " data_info = '", data_info_collapse, "',",
                             " model_dir = '", normalizePath(dirname_model_dir()), "',",
                             " python_loc = '", normalizePath(dirname_python_loc()), "',",
                             " log_dir_train = '", input$log_dir_train, "',\n",
                             "num_classes = ", input$num_classes, ",\n",
                             "architecture = '", input$architecture, "',\n",
                             "depth = ", input$depth, ",\n",
                             "num_cores = ", input$num_cores, ",\n",
                             "num_gpus = ", input$num_gpus, ",\n",
                             "retrain = ", input$retrain, ",\n",
                             "retrain_from = '", input$retrain_from, "',\n",
                             "top_n = ", input$top_n, ",\n", 
                             "num_epochs = ", input$num_epochs, ",",
                             "max_to_keep = ", input$max_to_keep, ",",
                             "randomize = ", input$randomize, ",",
                             "batch_size = ", input$batch_size, ",\n",
                             "os = '", os,
                             "'\n
    )"
    ))
  })
  output$helpText2 <- renderText({
    if(os=="Windows"){
      if(is.integer(inFile)){
        return("")
      } else{
        return("On Windows computers you cannot control the name of the trained model (=`log_dir_train`)
               The trained model will be saved in a folder named with the architecture you used and the time/date of training. 
               This folder will be stored within your MLWIC2_helper_files directory. \n")
      }
    } else{
      if(is.integer(inFile)){
        return("")
      } else{
        return("")
      }
    }
  })
  
  
  
  #- run train
  shiny::observeEvent(input$runTrain, {
    showModal(modalDialog("Running train function. Some output will appear in your R console during this process. You may press Dismiss at any time."))
    inFile <<- input$data_info
    if(is.integer(inFile)){
      return(NULL)
      #data_info_collapse <- ""
    } else{
      # on Windows deal with  issuefinding the right drive
      if(os == "Windows"){
        root <- inFile$root
        root1 <- gsub("\\(", "", root)
        root2 <- gsub("\\)", "", root1) # this gives [Drive]:
        data_info_collapse <- paste0(root2, paste0(inFile$files$`0`, collapse="/"))
      } else { # on not windows, we don't have to deal with this
        data_info_collapse <- paste0(inFile$files$`0`, collapse="/")
      }
    }
    train(#path_prefix = input$path_prefix,
      #path_prefix = renderText(dirname_path_prefix()),
      path_prefix = normalizePath(dirname_path_prefix()),
      #data_info = input$data_info,
      data_info = data_info_collapse,
      #model_dir = input$model_dir,
      model_dir = normalizePath(dirname_model_dir()),
      #python_loc = input$python_loc,
      python_loc = normalizePath(dirname_python_loc()),
      num_classes = input$num_classes,
      architecture = input$architecture,
      depth = input$depth,
      batch_size = input$batch_size,
      log_dir_train= input$log_dir_train,
      os = os,
      num_cores = input$num_cores,
      num_gpus = input$num_gpus,
      retrain = input$retrain,
      retrain_from = input$retrain_from,
      num_epochs = input$num_epochs,
      top_n = input$top_n,
      max_to_keep = input$max_to_keep,
      randomize = input$randomize,
      shiny=TRUE,
      print_cmd=FALSE
    )
    showModal(modalDialog("Train function complete. Check you R console for information. You may press dismiss and close the Shiny window now."))
  })
  
 
}

# UI
ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Train a machine learning model to recognize animals"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      #shiny::textOutput('path_prefix'),
      shinyFiles::shinyFilesButton('data_info', "Image label file", title="Select file containing file names of images and their classification", multiple=FALSE),
      #shiny::textOutput("data_info"),
      shinyFiles::shinyDirButton('model_dir', 'MLWIC2_helper_files directory', title="Find and select the MLWIC2_helper_files folder"),
      #shiny::textOutput('model_dir'),
      shinyFiles::shinyDirButton('python_loc', "Python location", title="Select the location of Python. It should be under Anaconda"),
      #shiny::textOutput('python_loc'),
      shiny::textInput("num_classes", "Number of classes in trained model (If you are using the built in model, you can leave all remaining windows with the default option)", formals(train)[["num_classes"]]),
      shiny::textInput("log_dir_train", "Desired name of trained model (=`log_dir_train`)", formals(train)[["log_dir_train"]]),
      shiny::textInput("architecture", "CNN Architecture: must be either `alexnet`, `densenet`, `googlenet`, `nin`, `resnet`, `vgg`", formals(train)[["architecture"]]),
      shiny::textInput("depth", "CNN Depth: if architecture=renset, this must be either (18, 34, 50, 101, 152). If architecture=densenet, this must be either (121, 161, 169, 201). Otherwise, automatic", formals(train)[["depth"]]),
      shiny::textInput("batch_size", "Batch size", formals(train)[["batch_size"]]),
      shiny::textInput("num_cores", "Number of cores to use, fewer will take longer, but more will use more of your computer.", formals(train)[["num_cores"]]),
      shiny::textInput("num_gpus", "Number of GPUs to use. If you don't have a GPU, ignore. ", formals(train)[["num_gpus"]]),
      shiny::selectInput("retrain", "Are you retraining a model?", choices=c(
        "No" = "FALSE",
        "Yes" = "TRUE"
      )),
      shiny::textInput("retrain_from", "Name of model you are retraining from", formals(train)[["retrain_from"]]),
      shiny::textInput("num_epochs", "Number of epochs to use for training", formals(train)[["num_epochs"]]),
      shiny::textInput("top_n", "Number of guesses to save", formals(train)[["top_n"]]),
      shiny::textInput("max_to_keep", "Maximum number of checkpoints to save", formals(train)[["max_to_keep"]]),
      shiny::selectInput("randomize", "Do you want to randomize the order of images for training", c(
        "Yes" = "TRUE",
        "No" = "FALSE"
      )),
      shiny::actionButton("runTrain", "Train model")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      shiny::helpText("After selecting inputs, you can use the values below in the train() function instead of running Shiny.
                      This printout is designed to allow you to avoid using Shiny in future runs."),
      shiny::textOutput("print"),
      shiny::textOutput("helpText2")
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server)
