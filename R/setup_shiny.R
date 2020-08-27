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

ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Setup environment for running MLWIC2"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      shinyFiles::shinyDirButton('python_loc', "Python location", title="Select the location of Python. It should be under Anaconda. Just select the folder where it resides in the top half of the menu and press `Select`"),
      #shiny::textOutput('python_loc'),
      shiny::selectInput("r_reticulate", "Have you already installed packages in aconda environment called `r-reticulate` that you want to keep?
                         If you don't understand, click `No`", 
                         choices = c(
                           "No" = FALSE,
                           "Yes" = TRUE
                         )),
      shiny::selectInput("gpu", "Do you have a GPU on your machine that you are planning to use?
                         If you don't understand, click `No`", 
                         choices = c(
                           "No" = FALSE,
                           "Yes" = TRUE
                         )),
      shiny::actionButton("runSetup", "Run Setup Function")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      shiny::helpText("If this shiny app throws an error, paste what is below into your R console to run setup."),
      shiny::textOutput("python_loc_print")
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server)

