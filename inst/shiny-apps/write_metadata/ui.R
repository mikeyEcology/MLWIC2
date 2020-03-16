ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Write classifications from MLWIC2 to metadata ofimage files"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      shinyFiles::shinyFilesButton('output_file', "Output file from classify", title="Select the file containing predictions from classify. This is in your MLWIC2_helper_files folder unless you deviated from defaults. ", multiple=FALSE),
      shiny::helpText("You only need to select ExifTool location if your computer is having trouble finding it. Windows users will likely need to do this"),
      shinyFiles::shinyDirButton('exiftool_loc', 'ExifTool location', title='Select the directory where ExifTool is stored.'),
      shiny::selectInput('model_type', 'What type of model did you use for classification', c(
        "species model" = "species_model",
        "empty-animal model" = "empty_animal"
      )),
      shiny::selectInput("show_sys_output", "Do you want to show output from the Exiftool call in your R console? (Only for troubleshooting)", c(
        "No" = "FALSE",
        "Yes" = "TRUE"

      )),
      shiny::actionButton("runwrite_metadata", "Write metadata")
    ),
    
    shiny::mainPanel(
      shiny::helpText("Output for copying and pasting into console:"),
      shiny::textOutput("print")
    )
  )
)

