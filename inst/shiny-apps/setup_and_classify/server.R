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
      MLWIC2::setup_and_classify(
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
