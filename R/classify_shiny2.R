# shiny
server <- function(input, output, session) {
  
  #- make file selection for some variables
  # base directory for fileChoose
  #volumes =  c(home = "") 
  volumes = shinyFiles::getVolumes()
  # path_prefix
  shinyFiles::shinyDirChoose(input, 'path_prefix', roots=volumes, session=session)
  dirname_path_prefix <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$path_prefix)})
  # Observe path_prefix changes
  shiny::observe({
    if(!is.null(dirname_path_prefix)){
      print(dirname_path_prefix())
      output$path_prefix <- shiny::renderText(dirname_path_prefix())
    }
  })
  # data_info
  shinyFiles::shinyFileChoose(input, "data_info", roots=volumes, session=session, filetypes=c('txt', 'csv'))
  filename_data_info <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$data_info)[length(shinyFiles::parseFilePaths(volumes, input$data_info))]})
  # observeEvent(input$data_info, {
  #   filename <- parseFilePaths(volumes, input$data_info)
  #   output$data_info <- renderText(filename$datapath)
  # })
  # model_dir
  shinyFiles::shinyDirChoose(input, 'model_dir', roots=volumes, session=session)
  dirname_model_dir <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$model_dir)})
  # Observe model_dir changes
  observe({
    if(!is.null(dirname_model_dir)){
      print(dirname_model_dir())
      output$model_dir <- shiny::renderText(dirname_model_dir())
    }
  })
  # python_loc
  shinyFiles::shinyDirChoose(input, 'python_loc', roots=volumes, session=session)
  dirname_python_loc <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$python_loc)})
  # Observe python_loc changes
  shiny::observe({
    if(!is.null(dirname_python_loc)){
      print(dirname_python_loc())
      output$python_loc <- shiny::renderText(dirname_python_loc())
    }
  })

  #- run classify
  shiny::observeEvent(input$runClassify, {
    MLWIC2::classify(#path_prefix = input$path_prefix,
      #path_prefix = renderText(dirname_path_prefix()),
      path_prefix = normalizePath(dirname_path_prefix()), #%%% I think I need to put normalizePath() on these
             #data_info = input$data_info,
      data_info = normalizePath(filename_data_info()),
             #model_dir = input$model_dir,
      model_dir = normalizePath(dirname_model_dir()),
             save_predictions = input$save_predictions,
             #python_loc = input$python_loc,
      python_loc = normalizePath(dirname_python_loc()),
             num_classes = input$num_classes,
             architecture = input$architecture,
             depth = input$depth,
             top_n = input$top_n,
             batch_size = input$batch_size,
             log_dir= input$log_dir,
      shiny=TRUE,
      make_output=TRUE,
      output_name=input$output_name,
      print_cmd=FALSE
    )
  })

}

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

# function that uses these
shiny::shinyApp(ui, server)

# put in these vlues
#path prefix: /Users/mikeytabak/Desktop/APHIS/mtMoran_projects/MLWIC_dir/MLWIC_package/MLWIC_examples/MLWIC_examples/images
#image label location: /Users/mikeytabak/Desktop/APHIS/mtMoran_projects/MLWIC_dir/MLWIC_package/MLWIC_examples/MLWIC_examples/image_labels.csv
#model directory: /Users/mikeytabak/Desktop/APHIS/teton_projects/trained_model_20190610/fitted_model/
#python: /anaconda3/bin/
