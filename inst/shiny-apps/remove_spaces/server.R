server <- function(input, output, session) {
  
  #- make file selection for some variables
  # base directory for fileChoose
  volumes = shinyFiles::getVolumes()
  # path
  shinyFiles::shinyDirChoose(input, 'path', roots=volumes(), session=session)
  dirname_path <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$path)})
  # Observe path changes
  shiny::observe({
    if(!is.null(dirname_path)){
      print(dirname_path())
      output$path <- shiny::renderText(dirname_path())
    }
  })
  
  #- run function
  shiny::observeEvent(input$runRemove_spaces, {
    remove_spaces(
      path = normalizePath(dirname_path()),
      pattern = input$pattern,
      copy=input$copy
    )
  })
  
}
