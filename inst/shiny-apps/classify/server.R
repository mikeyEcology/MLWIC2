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
  # shinyFiles::shinyFileChoose(input, "data_info", roots=volumes, session=session, filetypes=c('txt', 'csv'))
  # filename_data_info <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$data_info)[length(shinyFiles::parseFilePaths(volumes, input$data_info))]})
  # data_info directory = data_prefix
  shinyFiles::shinyDirChoose(input, 'data_prefix', roots=volumes, session=session)
  dirname_data_prefix <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$data_prefix)})
  # Observe data_prefix changes
  shiny::observe({
    if(!is.null(dirname_data_prefix)){
      print(dirname_data_prefix())
      output$data_prefix <- shiny::renderText(dirname_data_prefix())
    }
  })
  
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
  
  
  # print output for running function
  #  if(Windows){
  # print output for running function as one element
  output$path_prefix_print <- renderText({
    gsub("\\\\", "/", paste0("classify(\n
                               path_prefix = '", normalizePath(dirname_path_prefix()), "',",
                             " data_info = '", normalizePath(dirname_data_prefix()), slash(), input$data_info, "',",
                             " model_dir = '", normalizePath(dirname_model_dir()), "',",
                             " python_loc = '", normalizePath(dirname_python_loc()), "',",
                             " log_dir = '", input$log_dir, "',\n",
                             "num_classes = ", input$num_classes, ",\n",
                             "save_predictions = '", input$save_predictions, "',\n",
                             "architecture = '", input$architecture, "',\n",
                             "depth = ", input$depth, ",\n",
                             "num_cores = ", input$num_cores, ",\n",
                             "top_n = ", input$top_n, ",\n",
                             "batch_size = ", input$batch_size, ",\n",
                             "output_name = '", input$output_name, "',\n",
                             "os = '", os,
                             "'\n
      )"
    ))
  })
  
  #- run classify
  shiny::observeEvent(input$runClassify, {
    classify(#path_prefix = input$path_prefix,
      #path_prefix = renderText(dirname_path_prefix()),
      path_prefix = gsub("\\\\", "/", normalizePath(dirname_path_prefix())),
      #data_info = input$data_info,
      #data_info = normalizePath(filename_data_info()),
      data_info =  gsub("\\\\", "/", paste0(normalizePath(dirname_data_prefix()), slash(), input$data_info)),
      #data_info =  paste0(normalizePath(dirname_data_prefix()), slash(), input$data_info),
      #model_dir = input$model_dir,
      #model_dir =  gsub("\\\\", "/", normalizePath(dirname_model_dir())),
      model_dir =  normalizePath(dirname_model_dir()),
      save_predictions = input$save_predictions,
      #python_loc = input$python_loc,
      python_loc =  gsub("\\\\", "/", paste0(normalizePath(dirname_python_loc()), "/")),
      #python_loc = paste0(normalizePath(dirname_python_loc())),
      num_classes = input$num_classes,
      architecture = input$architecture,
      depth = input$depth,
      num_cores = input$num_cores,
      top_n = input$top_n,
      batch_size = input$batch_size,
      log_dir= input$log_dir,
      shiny=TRUE,
      make_output=FALSE,
      output_name=input$output_name,
      test_tensorflow = FALSE,
      os = os,
      print_cmd=FALSE
    )
  })
  
  
  # pass output to another function
  observe({
    windows_input <<- gsub("\\\\", "/", paste0("classify(path_prefix = '", normalizePath(dirname_path_prefix()), "',", " data_info = '", normalizePath(dirname_data_prefix()), slash(), input$data_info, "',", " model_dir = '", normalizePath(dirname_model_dir()), "',", " python_loc = '", normalizePath(dirname_python_loc()), "',"," log_dir = '", input$log_dir, "',"," num_classes = ", input$num_classes, ","," save_predictions = '", input$save_predictions, "',", " architecture = '", input$architecture,"',", " depth = ", input$depth, ",", " num_cores = ", input$num_cores, ",","top_n = ", input$top_n, ",","batch_size = ", input$batch_size,",","output_name = '", input$output_name,"')"
    ))
  })
  
  # windows_input <<- shiny::reactive({
  #   gsub("\\\\", "/", paste0("classify(\n
  #                            path_prefix = '", normalizePath(dirname_path_prefix()), "',",
  #                            " data_info = '", normalizePath(dirname_data_prefix()), slash(), input$data_info, "',",
  #                            " model_dir = '", normalizePath(dirname_model_dir()), "',",
  #                            " python_loc = '", normalizePath(dirname_python_loc()), "',",
  #                            " log_dir = '", input$log_dir, "',\n",
  #                            "num_classes = ", input$num_classes, ",\n",
  #                            "save_predictions = '", input$save_predictions, "',\n",
  #                            "architecture = '", input$architecture, "',\n",
  #                            "depth = ", input$depth, ",\n",
  #                            "num_cores = ", input$num_cores, ",\n",
  #                            "top_n = ", input$top_n, ",\n",
  #                            "batch_size = ", input$batch_size, ",\n",
  #                            "output_name = '", input$output_name,
  #                            "'\n
  #   )"
  #     ))
  # })
  # shiny::observeEvent(input$runClassify, {
  #   windows_helper(renderPrint(windows_input(), quoted=TRUE))
  # })
  #
  
}
