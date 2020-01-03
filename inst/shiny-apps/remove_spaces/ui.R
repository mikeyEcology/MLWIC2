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
