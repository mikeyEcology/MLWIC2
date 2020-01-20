server <- function(input, output, session) {
  
  #- make file selection for some variables
  # base directory for fileChoose
  #volumes =  c(home = "") 
  volumes = shinyFiles::getVolumes()
  shinyFiles::shinyDirChoose(input, 'python_loc', roots=volumes, session=session)
  dirname_python_loc <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$python_loc)})
  # Observe python_loc changes
  shiny::observe({
    if(!is.null(dirname_python_loc)){
      print(dirname_python_loc())
      output$python_loc <- shiny::renderText(dirname_python_loc())
    }
  })
  
  output$python_loc_print <- renderText({
    paste0("python_loc = '", normalizePath(dirname_python_loc()), "'\n")
  })
  
  #- run classify
  shiny::observeEvent(input$runShiny, {
    setup(
      python_loc = normalizePath(dirname_python_loc()),
      conda_loc = "auto",
      r_reticulate = input$r_reticulate
    )
  })
  
}
