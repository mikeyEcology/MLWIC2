ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Make input files for MLWIC2"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::helpText("If you are providing a csv containing image file names and their classifications, select it using the `Image label file button`. Otherwise skip this button."),
      shinyFiles::shinyFilesButton('input_file', "Image label file", title="Select a csv containing file names of images and their classification", multiple=FALSE),
      shinyFiles::shinyDirButton('output_dir', "Directory to store Input file", title="Select the directory where you want to store your input file. Your MLWIC2_helper_files folder would be a good place for this."),
      shiny::selectInput("option", "Which Option number do you want to use? See description to the right", c(
        "1" = "1",
        "2" = "2",
        "3" = "3",
        "4" = "4",
        "5" = "5"
      )),
      shiny::helpText("Only select Image directory button if you are using Option 4."),
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      shiny::helpText("Recursive option is only relevant if you are using Option 4."),
      shiny::selectInput("recursive", "Are the images all directly in your Image directory? Selecting Yes means that
                         you do not have images stored in sub-folders within this folder", c(
                           "No" = "TRUE",
                           "Yes" = "FALSE" # yes is false because recusrive is false
                         )),
      shiny::selectInput("model_type", "Which model type are you using? If you trained your own model, ignore", c(
        "Species model" = "species_model",
        "Empty/Animal model" = "empty_animal"
      )),
      shiny::helpText("Only set training proportion if you are using option 5."),
      shiny::textInput("propTrain", "Proportion of images for training.", formals(classify)[["propTrain"]]),
      shiny::actionButton("runMake_input", "Make an input file")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      shiny::helpText("Option 1: If you have labels for your images and you want to test the model on your images, you need to have an `input_file` csv that has at last two columns and one of these must be 'filename' and the other must be 'class_ID'.\n
                      Option 2: This is the same as option 1, excpet instead of having a column `class_ID` containing the number associated with each species, you have a column called `class` containing your classifications as words (e.g., 'dog' or 'cattle', 'empty'), the function will find the appropriate `class_ID` associated with these words.
                      Option 3: If you do not have your images classified, but you have all of the filenames for the images you want to classify, you can have an `input_file` csv in your with a column called 'filename' and whatever other columns you would like.
                      Option 4:  MLWIC2 can find the filenames of all of your images and create your input file. For this option, you need to specify your `path_prefix` which is the parent directory of your images.
                      Option 5: If you are planning to train a model, you will want training and testing sets of images. This function will set up these files also, see `?make_input` for more details.")
    )
  )
)
