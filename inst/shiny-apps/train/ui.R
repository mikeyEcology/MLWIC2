# UI
ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Train a machine learning model to recognize animals"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      shiny::textOutput('path_prefix'),
      shinyFiles::shinyFilesButton('data_info', "Image label file", title="Select file containing file names of images and their classification", multiple=FALSE),
      shiny::textOutput("data_info"),
      shinyFiles::shinyDirButton('model_dir', 'Trained model directory', title="Select the location where you stored the 'trained_model' folder"),
      shiny::textOutput('model_dir'),
      shinyFiles::shinyDirButton('python_loc', "Python location", title="Select the location of Python. It should be under Anaconda"),
      shiny::textOutput('python_loc'),
      shiny::textInput("num_classes", "Number of classes in trained model (If you are using the built in model, leave all remaining windows with the default option)", formals(MLWIC2::train)[["num_classes"]]),
      shiny::textInput("log_dir_train", "Directory name of trained model", formals(MLWIC2::train)[["log_dir_train"]]),
      shiny::textInput("architecture", "CNN Architecture", formals(MLWIC2::train)[["architecture"]]),
      shiny::textInput("depth", "CNN Depth", formals(MLWIC2::train)[["depth"]]),
      shiny::textInput("batch_size", "Batch size", formals(MLWIC2::train)[["batch_size"]]),
      shiny::selectInput("os", "Operating system type", choices=c(
        "MacIntosh" = "Mac",
        "Windows"= "Windows",
        "Ubuntu" = "Ubuntu"
      )),
      shiny::textInput("num_gpus", "Number of GPUs to use", formals(MLWIC2::train)[["num_gpus"]]),
      shiny::selectInput("retrain", "Are you retraining a model?", choices=c(
        "Yes" = "TRUE",
        "No" = "FALSE"
      )),
      shiny::textInput("retrain_from", "Name of model you are retraining from", formals(MLWIC2::train)[["retrain_from"]]),
      shiny::textInput("num_epochs", "Number of epochs to use for training", formals(MLWIC2::train)[["num_epochs"]]),
      shiny::textInput("max_to_keep", "Maximum number of checkpoints to save", formals(MLWIC2::train)[["max_to_keep"]]),
      shiny::selectInput("randomize", "Do you want to randomize the order of images for training", c(
        "Yes" = "TRUE",
        "No" = "FALSE"
      )),
      shiny::actionButton("runTrain", "Train model")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
    )
  )
)

