
ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Classify images using MLWIC2"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(

    shiny::sidebarPanel(
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      shiny::textOutput('path_prefix'),
      #textInput("path_prefix", "Path Prefix"),
      #textInput("data_info", "Image Label Location"),
      shinyFiles::shinyFilesButton('data_info', "Image label file", title="Select file containing file names of images and their classification", multiple=FALSE),
      shiny::textOutput("data_info"),
      #textInput("model_dir", "Model Directory"),
      shinyFiles::shinyDirButton('model_dir', 'Trained model directory', title="Select the location where you stored the 'trained_model' folder"),
      shiny::textOutput('model_dir'),
      #textInput("python_loc", "Location of Python on your computer"),
      shinyFiles::shinyDirButton('python_loc', "Python location", title="Select the location of Python. It should be under Anaconda"),
      shiny::textOutput('python_loc'),
      shiny::textInput("num_classes", "Number of classes in trained model (If you are using the built in model, leave all remaining windows with the default option)", formals(MLWIC2::classify)[["num_classes"]]),
      shiny::textInput("save_predictions", "Name of text file to save predictions (must end in .txt)", formals(MLWIC2::classify)[["save_predictions"]]) ,
      shiny::textInput("log_dir", "Directory name of trained model", formals(MLWIC2::classify)[["log_dir"]]),
      shiny::textInput("architecture", "CNN Architecture", formals(MLWIC2::classify)[["architecture"]]),
      shiny::textInput("depth", "CNN Depth", formals(MLWIC2::classify)[["depth"]]),
      shiny::textInput("top_n", "Number of guesses to save", formals(MLWIC2::classify)[["top_n"]]),
      shiny::textInput("batch_size", "Batch size", formals(MLWIC2::classify)[["batch_size"]]),
      shiny::textInput("output_name", "Name of cleaned output file", formals(MLWIC2::classify)[["output_name"]]),
      shiny::actionButton("runClassify", "Run Classify Function")
    ), # this works with option 2
  
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(

    )
  )
)
