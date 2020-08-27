server <- function(input, output, session) {
  
  #- make file selection for some variables
  # base directory for fileChoose
  #volumes =  c(home = "")
  volumes = shinyFiles::getVolumes()
  
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
  
  output$python_loc_print <- renderText({
    paste0("MLWIC2::setup(python_loc = '", normalizePath(dirname_python_loc()), "', ",
           "r-reticulate = ", input$r_reticulate, ", ",
           "gpu = ", input$gpu, ")",
           
           "\n")
  })
  
  #- run classify
  shiny::observeEvent(input$runSetup, {
    shiny::showModal(modalDialog("Setting up environment. Check R console for updates; Press Dismiss at any time"))
    setup(
      python_loc = gsub("\\\\", "/", paste0(normalizePath(dirname_python_loc()), "/")),
      conda_loc = "auto",
      #r_reticulate = promises::promise_resolve(input$r_reticulate),
      gpu = input$gpu
    )
    showModal(modalDialog("Setup function complete."))
  })
  
}
