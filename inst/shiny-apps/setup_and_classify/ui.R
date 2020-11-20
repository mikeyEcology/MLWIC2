ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Setup MLWIC2 for your computer and classify images"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shinyFiles::shinyDirButton('python_loc', "Python location", title="Select the location of Python. It should be under Anaconda"),
      shiny::textOutput('python_loc'),
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      shiny::textOutput('path_prefix'),
      shiny::selectInput("recursive", "Are your images stored in sub-folders within this folder? Or are they all directly in this folder?",
                         choices=c(
                           "Stored in sub-folders" = "TRUE",
                           "All images are in this folder" = "FALSE"
                         )),
      shiny::selectInput("os", "Operating system type", choices=c(
        "MacIntosh" = "Mac",
        "Windows"= "Windows",
        "Ubuntu" = "Ubuntu"
      )),
      shiny::selectInput("already_downloaded_model", "Have you already downloaded the trained model?",
                         choices = c(
                           "No" = "FALSE",
                           "Yes" = "TRUE"
                         )),
      shinyFiles::shinyDirButton('model_dir', 'MLWIC2_helper_files directory', title="If you have already downloaded the MLWIC2_helper_files folder, select its location. Otherwise, select `cancel`"),
      shiny::textOutput('model_dir'),
      shiny::selectInput("tensorflow_installed", "Have you already installed tensorflow on your machine?",
                         choices = c(
                           "No" = "FALSE",
                           "Yes" = "TRUE"
                         )),
      shiny::selectInput("MLWIC2_already_setup", "Have you already setup your machine to run MLWIC2?",
                         choices = c(
                           "No" = "FALSE",
                           "Yes" = "TRUE"
                         )),
      shiny::selectInput("model_type", "What type of model do you want to use?",
                         choices = c(
                           "Animal / Empty" = "empty_animal",
                           "Identify animal species" = "species_model",
                           "CFTEP" = "CFTEP"
                         )),
      
      shiny::textInput("output_name", "Name of cleaned output file"
                       #, formals(setup_and_classify)[["output_name"]]
      ),
      shiny::actionButton("runSetup_and_classify", "Setup MLWIC2 and classify images")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
    )
  )
)
