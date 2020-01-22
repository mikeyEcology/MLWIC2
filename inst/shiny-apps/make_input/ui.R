
ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Make input files for MLWIC2"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::helpText("If you are providing a csv containing image file names and their classifications, select it using the `Image label file button`. Otherwise skip this button."),
      shinyFiles::shinyFilesButton('input_file', "Image label file", title="Select a csv containing file names of images and their classification", multiple=FALSE),
      shiny::selectInput("find_file_names", "Do you want MLWIC2 to find the names of your image files? 
                         This means that you will not be providing an Image label file", c(
                           "Yes" = "TRUE",
                           "No" = "FALSE"
                         )),
      shiny::helpText("Only select Image directory button if you want MLWIC2 to find your file names."),
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      shiny::selectInput("recursive", "Are the images all directly in your Image directory? Selecting Yes means that
                         you do not have images stored in sub-folders within this folder", c(
                           "No" = "TRUE",
                           "Yes" = "FALSE" # yes is false because recusrive is false
                         )),
      shiny::selectInput("usingBuiltIn", "Are you using one of the models that came with MLWIC2? 
                         If you are using a model that you trained, select No", c(
                           "Yes" = "TRUE", 
                           "No" = "FALSE"
                         )),
      shiny::selectInput("model_type", "Which model type are you using? If you trained your own model, ignore", c(
        "Species model" = "species_model", 
        "Empty/Animal model" = "empty_animal"
      )),
      shiny::selectInput("images_classified", "Have your images already been classified? (you know what species is in the images)", c(
        "Yes" = "TRUE", 
        "No" = "FALSE"
      )),
      shiny::selectInput("find_class_IDs", "Do you want MLWIC2 to find the class_IDs for each image? 
                         Selecting No means that (if your images are classified) you're providing an input file with class_IDs that match
                         the values found in this table (https://github.com/mikeyEcology/MLWIC2/blob/master/speciesID.csv)", c(
                           "Yes" = "TRUE", 
                           "No" = "FALSE"
                         )),
      shiny::selectInput("train_test", "Do you want MLWIC2 to make separate training and testing input files?
                         Select no unless you are trainig a model.", c(
                           "No" = "FALSE",
                           "Yes" = "TRUE"
                         )),
      shiny::textInput("propTrain", "Proportion of images for training. Unless you're setting up a training/testing dataset, ignore", formals(classify)[["propTrain"]]),
      shiny::actionButton("runMake_input", "Make an input file")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
    )
  )
)