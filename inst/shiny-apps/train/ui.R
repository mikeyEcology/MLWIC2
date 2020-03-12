ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Train a machine learning model to recognize animals"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      #shiny::textOutput('path_prefix'),
      shinyFiles::shinyFilesButton('data_info', "Image label file", title="Select file containing file names of images and their classification", multiple=FALSE),
      #shiny::textOutput("data_info"),
      shinyFiles::shinyDirButton('model_dir', 'MLWIC2_helper_files directory', title="Find and select the MLWIC2_helper_files folder"),
      #shiny::textOutput('model_dir'),
      shinyFiles::shinyDirButton('python_loc', "Python location", title="Select the location of Python. It should be under Anaconda"),
      #shiny::textOutput('python_loc'),
      shiny::textInput("num_classes", "Number of classes in trained model (If you are using the built in model, you can leave all remaining windows with the default option)", formals(train)[["num_classes"]]),
      shiny::textInput("log_dir_train", "Desired name of trained model (=`log_dir_train`)", formals(train)[["log_dir_train"]]),
      shiny::textInput("architecture", "CNN Architecture: must be either `alexnet`, `densenet`, `googlenet`, `nin`, `resnet`, `vgg`", formals(train)[["architecture"]]),
      shiny::textInput("depth", "CNN Depth: if architecture=renset, this must be either (18, 34, 50, 101, 152). If architecture=densenet, this must be either (121, 161, 169, 201). Otherwise, automatic", formals(train)[["depth"]]),
      shiny::textInput("batch_size", "Batch size", formals(train)[["batch_size"]]),
      shiny::textInput("num_cores", "Number of cores to use, fewer will take longer, but more will use more of your computer.", formals(train)[["num_cores"]]),
      shiny::textInput("num_gpus", "Number of GPUs to use. If you don't have a GPU, ignore. ", formals(train)[["num_gpus"]]),
      shiny::selectInput("retrain", "Are you retraining a model?", choices=c(
        "Yes" = "TRUE",
        "No" = "FALSE"
      )),
      shiny::textInput("retrain_from", "Name of model you are retraining from", formals(train)[["retrain_from"]]),
      shiny::textInput("num_epochs", "Number of epochs to use for training", formals(train)[["num_epochs"]]),
      shiny::textInput("top_n", "Number of guesses to save", formals(train)[["top_n"]]),
      shiny::textInput("max_to_keep", "Maximum number of checkpoints to save", formals(train)[["max_to_keep"]]),
      shiny::selectInput("randomize", "Do you want to randomize the order of images for training", c(
        "Yes" = "TRUE",
        "No" = "FALSE"
      )),
      shiny::actionButton("runTrain", "Train model")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      shiny::helpText("After selecting inputs, you can use the values below in the train() function instead of running Shiny.
                      This printout is designed to allow you to avoid using Shiny in future runs."),
      shiny::textOutput("print")
    )
  )
)

