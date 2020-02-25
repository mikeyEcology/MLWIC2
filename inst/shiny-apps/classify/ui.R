
ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("Classify images using MLWIC2"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    shiny::sidebarPanel(
      # shiny::selectInput("os", "What operating system are you running?",
      #                    choices = c(
      #                      "Windows" = "windows",
      #                      "Macintosh/linux" = "mac"
      #                    ), multiple=FALSE),
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      #shiny::textOutput('path_prefix'),
      shinyFiles::shinyDirButton('data_prefix', "Location of image label file", title="Select directory containing image label file (file with file names of images and their classification). When you see this label file in the lower half of the window, select the folder in the top half of the window."),
      #shiny::textOutput("data_info"),
      shiny::textInput('data_info', "Name of image label file (in the directory you just selected)", value="image_labels.csv"),
      shinyFiles::shinyDirButton('model_dir', 'MLWIC2_helper_files directory', title="Find and select the MLWIC2_helper_files folder"),
      #shiny::textOutput('model_dir'),
      #textInput("python_loc", "Location of Python on your computer"),
      shinyFiles::shinyDirButton('python_loc', "Python location", title="Select the location of Python on your computer. It should be under Anaconda"),
      #shiny::textOutput('python_loc'),
      shiny::textInput("log_dir", "Directory name of trained model. Either `species_model`, `empty_animal`, or if using a model you trained, it's what you set as your `log_dir_train`", formals(classify)[["log_dir"]]),
      shiny::textInput("num_classes", "Number of classes in trained model (If you are using the built in model, leave all remaining windows with the default option)", formals(classify)[["num_classes"]]),
      shiny::textInput("save_predictions", "Name of text file to save predictions (must end in .txt)", formals(classify)[["save_predictions"]]) ,
      shiny::textInput("architecture", "CNN Architecture", formals(classify)[["architecture"]]),
      shiny::textInput("depth", "CNN Depth", formals(classify)[["depth"]]),
      shiny::textInput("num_cores", "Number of cores to use", formals(classify)[["num_cores"]]),
      shiny::textInput("top_n", "Number of guesses to save", formals(classify)[["top_n"]]),
      shiny::textInput("batch_size", "Batch size (must be a multiple of 64)", formals(classify)[["batch_size"]]),
      shiny::textInput("output_name", "Name of cleaned output file", formals(classify)[["output_name"]]),
      shiny::actionButton("runClassify", "Run Classify Function")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      shiny::helpText("After selecting inputs, you can use the values below in the classify() function instead of running Shiny.
                      This printout is designed to allow you to avoid using Shiny in future runs."),
      shiny::textOutput("path_prefix_print")
    )
  )
)
