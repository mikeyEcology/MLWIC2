# shiny
server <- function(input, output, session) {
  
  # determine if Windows"
  if(Sys.info()["sysname"] == "Windows"){
    Windows <- TRUE
  }
  
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
  #filename_data_info <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$data_info)})
  # observe({
  #   if(!is.null(filename_data_info)){
  #     print(filename_data_info())
  #     output$data_info <- shiny::renderText(filename_data_info())
  #   }
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
  
  # print output for running function
  output$path_prefix_print <- renderText({
    paste0("classify(\n
           path_prefix = '", normalizePath(dirname_path_prefix()), "',")
  })
  output$data_info_print <- renderText({
    paste0("data_info = '", filename_data_info(), "',")
  })
  output$model_dir_print <- renderText({
    paste0("model_dir = '", normalizePath(dirname_model_dir()), "',")
  })
  output$python_loc_print <- renderText({
    paste0("python_loc = '", normalizePath(dirname_python_loc()), "'\n
           )")
  })
  
  #- run classify
  shiny::observeEvent(input$runClassify, {
    classify(#path_prefix = input$path_prefix,
      #path_prefix = renderText(dirname_path_prefix()),
      path_prefix = normalizePath(dirname_path_prefix()), 
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
      #test_tensorflow = FALSE,
      print_cmd=TRUE
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
      #shiny::textOutput('path_prefix'),
      shinyFiles::shinyFilesButton('data_info', "Image label file", title="Select file containing file names of images and their classification", multiple=FALSE),
      #shiny::textOutput("data_info"),
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
      shiny::textInput("top_n", "Number of guesses to save", formals(classify)[["top_n"]]),
      shiny::textInput("batch_size", "Batch size (must be a multiple of 64)", formals(classify)[["batch_size"]]),
      shiny::textInput("output_name", "Name of cleaned output file", formals(classify)[["output_name"]]),
      shiny::actionButton("runClassify", "Run Classify Function")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      shiny::helpText("After selecting the first 4 inputs, you can use the values below in the classify() function instead of running Shiny.
                      This printout is designed to help you find your paths."),
      shiny::textOutput("path_prefix_print"),
      shiny::textOutput("data_info_print"),
      shiny::textOutput("model_dir_print"),
      shiny::textOutput("python_loc_print")
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server)

