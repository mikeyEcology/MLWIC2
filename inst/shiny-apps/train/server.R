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
  
  # print output for running function as one element
  output$print <- renderText({
    inFile <<- input$data_info
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
                             " log_dir = '", input$log_dir, "',\n",
                             " log_dir_train = '", input$log_dir_train, "',\n",
                             "num_classes = ", input$num_classes, ",\n",
                             "save_predictions = '", input$save_predictions, "',\n",
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
                             "output_name = '", input$output_name, "',\n",
                             "os = '", os,
                             "'\n
    )"
    ))
  })
  
  
  #- run train
  shiny::observeEvent(input$runTrain, {
    showModal(modalDialog("Running train function. Some output will appear in your R console during this process. You may press Dismiss at any time."))
    inFile <- input$data_info
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
      max_to_keep = input$max_to_keep,
      randomize = input$randomize,
      shiny=TRUE,
      print_cmd=FALSE
    )
    showModal(modalDialog("Train function complete. Check you R console for information. You may press dismiss and close the Shiny window now."))
  })
  
 
}
