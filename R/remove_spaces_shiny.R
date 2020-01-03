server <- function(input, output, session) {
  
  #- make file selection for some variables
  # base directory for fileChoose
  volumes = shinyFiles::getVolumes()
  # path
  shinyFiles::shinyDirChoose(input, 'path', roots=volumes, session=session)
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

ui <- shiny::fluidPage(
  # App title ----
  shiny::titlePanel("Remove spaces from file names"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      shinyFiles::shinyDirButton('path', 'Image directory', title='Select the directory where you have files with spaces in the names'),
      shiny::textInput("pattern", "Enter the suffix for file names (or file extention)", ".jpg"), #, formals(remove_spaces)[["pattern"]]),
      shiny::selectInput("copy", "Do you want to copy files or replace them?", c(
        "Copy" = "TRUE",
        "Relace" = "FALSE"
      )),
      shiny::actionButton("runRemove_spaces", "Remove Spaces")
    ),
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
    )
  )
)

shiny::shinyApp(ui, server)
