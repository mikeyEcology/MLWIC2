# shiny
server <- function(input, output, session) {
  
  # determine if Windows and create appropriate slashes
  if(Sys.info()["sysname"] == "Windows"){
    Windows <- TRUE
  } else {
    Windows <- FALSE
  }
  slash <- shiny::reactive({ifelse(Windows, "\\", "/")})
  os = ifelse(Windows, "Windows", "Mac")
  
  #- make file selection for some variables
  # base directory for fileChoose
  #volumes =  c(home = "")
  volumes = shinyFiles::getVolumes()
  # input_file
  shinyFiles::shinyFileChoose(input, "input_file", roots=volumes, session=session, filetypes=c('txt', 'csv'))
  filename_input_file <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$input_file)[length(shinyFiles::parseFilePaths(volumes, input$input_file))]})
  #filename_input_file <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$input_file)})
  # path_prefix
  shinyFiles::shinyDirChoose(input, 'path_prefix', roots=volumes, session=session)
  dirname_path_prefix <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$path_prefix)})
  # Observe path_prefix changes
  shiny::observe({
    if(!is.null(dirname_path_prefix)){
      print(dirname_path_prefix())
      output$path_prefix <- shiny::renderText(dirname_path_prefix())
    } else{
      output$path_prefix <- getwd()
    }
  })
  # observe filename changes
  # shiny::observe({
  #   if(!is.null(filename_input_file)){
  #     print(filename_input_file())
  #     output$input_file <- shiny::renderText(filename_input_file())
  #   }
  # })
  
  
  
  #- run classify
  shiny::observeEvent(input$runMake_input, {
    # dealing with null path prefix
    # if(is.null(dirname_path_prefix)){
    #   path_prefix <- getwd()
    # } else{
    #   print(dirname_path_prefix())
    #   #path_prefix1 <- shiny::renderText(dirname_path_prefix())
    #   path_prefix <- gsub("\\\\", "/", normalizePath(dirname_path_prefix()))
    # }
    # do this to read file in shiny
    inFile <<- input$input_file
    if(is.integer(inFile)){
      return(NULL)
    } else{
      # on Windows deal with  issuefinding the right drive
      if(os == "Windows"){
        root <- inFile$root
        root1 <- gsub("\\(", "", root)
        root2 <- gsub("\\)", "", root1) # this gives [Drive]:
        inFile_collapse <- paste0(root2, paste0(inFile$files$`0`, collapse="/"))
      } else { # on not windows, we don't have to deal with this
        inFile_collapse <- paste0(inFile$files$`0`, collapse="/")
      }
    }
    make_input(
      showModal(modalDialog("Making input file(s). You may press dismiss at any time. Check your R console for more information. A warning message about invalid argument type is expected.")),
      #input_file = normalizePath(filename_input_file()),
      input_file = inFile_collapse,
      find_file_names = input$find_file_names,
      path_prefix = gsub("\\\\", "/", normalizePath(dirname_path_prefix())),
      #path_prefix = path_prefix,
      image_file_suffixes = c(".jpg", ".JPG"),
      recursive = input$recursive,
      usingBuiltIn = input$usingBuiltIn,
      model_type = input$model_type,
      images_classified = input$images_classified,
      find_class_IDs = input$find_class_IDs,
      trainTest = input$train_test,
      file_prefix = "",
      shiny=TRUE,
      propTrain = input$propTrain
    )
  })
  
}

