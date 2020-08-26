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
      shiny::helpText("For future reference, this is your python_loc"),
      shiny::textOutput("python_loc_print")
    )
  )
)
