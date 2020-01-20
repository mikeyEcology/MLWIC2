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

ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Setup environment for running MLWIC2"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      shinyFiles::shinyDirButton('python_loc', "Python location", title="Select the location of Python. It should be under Anaconda"),
      #shiny::textOutput('python_loc'),
      shiny::selectInput("r_reticulate", "Have you already installed packages in an environment called `r-reticulate that you want to keep?
                         If you don't understand, click `No`", 
                         choices = c(
                           "No" = FALSE,
                           "Yes" = TRUE
                         )),
      shiny::actionButton("runSetup", "Run Setup Function")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      shiny::helpText("For future reference, this is your python_loc"),
      shiny::textOutput("python_loc_print")
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server)

