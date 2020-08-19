# shiny
server <- function(input, output, session) {
  
  # determine if Windows and create appropriate slashes
  if(Sys.info()["sysname"] == "Windows"){
    Windows <- TRUE
  } else {
    Windows <- FALSE
  }
  slash <- shiny::reactive({ifelse(Windows, "\\", "/")})
  os = ifelse(Windows, "Windows", "Mac")
  
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
  # data_info directory = data_prefix
  # shinyFiles::shinyDirChoose(input, 'data_prefix', roots=volumes, session=session)
  # dirname_data_prefix <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$data_prefix)})
  # # Observe data_prefix changes
  # shiny::observe({
  #   if(!is.null(dirname_data_prefix)){
  #     print(dirname_data_prefix())
  #     output$data_prefix <- shiny::renderText(dirname_data_prefix())
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
  #  if(Windows){
  # print output for running function as one element
  output$path_prefix_print <- renderText({
    inFile <- input$data_info
    if(is.integer(inFile)){
      return("This printout will appear once you select your input file.")
    } else{
      # on Windows deal with  issuefinding the right drive
      if(os == "Windows"){
        root <- inFile$root
        root1 <- gsub("\\(", "", root)
        root2 <- gsub("\\)", "", root1) # this gives [Drive]:
        data_info_collapse <- paste0(root2, paste0(inFile$files$`0`, collapse="/"))
      } else { # on not windows, we don't have to deal with this
        data_info_collapse <- paste0(inFile$files$`0`, collapse="/")
      }
    }
    gsub("\\\\", "/", paste0("classify(\n
                              path_prefix = '", normalizePath(dirname_path_prefix()), "',",
                             " data_info = '", data_info_collapse, "',",
                             #" data_info = '", normalizePath(dirname_data_prefix()), slash(), input$data_info, "',",
                             " model_dir = '", normalizePath(dirname_model_dir()), "',",
                             " python_loc = '", normalizePath(dirname_python_loc()), "',",
                             " log_dir = '", input$log_dir, "',\n",
                             "num_classes = ", input$num_classes, ",\n",
                             "save_predictions = '", input$save_predictions, "',\n",
                             "architecture = '", input$architecture, "',\n",
                             "depth = ", input$depth, ",\n",
                             "num_cores = ", input$num_cores, ",\n",
                             "top_n = ", input$top_n, ",\n", 
                             "batch_size = ", input$batch_size, ",\n",
                             "output_name = '", input$output_name, "',\n",
                             "os = '", os,
                             "'\n
      )"
    ))
  })

  
  #- run classify
  shiny::observeEvent(input$runClassify, {
    showModal(modalDialog("Running classify function. Some output will appear in your R console during this process."))
    inFile <<- input$data_info
    if(is.integer(inFile)){
      return(NULL)
      #data_info_collapse <- ""
    } else{
      # on Windows deal with  issuefinding the right drive
      if(os == "Windows"){
        root <- inFile$root
        root1 <- gsub("\\(", "", root)
        root2 <- gsub("\\)", "", root1) # this gives [Drive]:
        data_info_collapse <- paste0(root2, paste0(inFile$files$`0`, collapse="/"))
      } else { # on not windows, we don't have to deal with this
        data_info_collapse <- paste0(inFile$files$`0`, collapse="/")
      }
    }
    classify(#path_prefix = input$path_prefix,
      #path_prefix = renderText(dirname_path_prefix()),
      path_prefix = gsub("\\\\", "/", normalizePath(dirname_path_prefix())),
      data_info = data_info_collapse, 
      #data_info = input$data_info,
      #data_info = normalizePath(filename_data_info()),
      #data_info =  gsub("\\\\", "/", paste0(normalizePath(dirname_data_prefix()), slash(), input$data_info)),
      #data_info =  paste0(normalizePath(dirname_data_prefix()), slash(), input$data_info),
      #model_dir = input$model_dir,
      #model_dir =  gsub("\\\\", "/", normalizePath(dirname_model_dir())),
      model_dir =  normalizePath(dirname_model_dir()),
      save_predictions = input$save_predictions,
      #python_loc = input$python_loc,
      python_loc =  gsub("\\\\", "/", paste0(normalizePath(dirname_python_loc()), "/")),
      #python_loc = paste0(normalizePath(dirname_python_loc())),
      num_classes = input$num_classes,
      architecture = input$architecture,
      depth = input$depth,
      num_cores = input$num_cores,
      top_n = input$top_n,
      batch_size = input$batch_size,
      log_dir= input$log_dir,
      shiny=TRUE,
      make_output=TRUE,
      output_name=input$output_name,
      test_tensorflow = FALSE,
      os = os,
      print_cmd=FALSE
    )
    showModal(modalDialog("Classify function complete. Check you R console for information. You may press dismiss and close the Shiny window now."))
  })
  
  
  # pass output to another function
  # observe({
  #   #windows_input <<- gsub("\\\\", "/", paste0("classify(path_prefix = '", normalizePath(dirname_path_prefix()), "',", " data_info = '", normalizePath(dirname_data_prefix()), slash(), input$data_info, "',", " model_dir = '", normalizePath(dirname_model_dir()), "',", " python_loc = '", normalizePath(dirname_python_loc()), "',"," log_dir = '", input$log_dir, "',"," num_classes = ", input$num_classes, ","," save_predictions = '", input$save_predictions, "',", " architecture = '", input$architecture,"',", " depth = ", input$depth, ",", " num_cores = ", input$num_cores, ",","top_n = ", input$top_n, ",","batch_size = ", input$batch_size,",","output_name = '", input$output_name,"')"
  #   #                                           ))
  #   windows_input <<- list(path_prefix = gsub("\\\\", "/", normalizePath(dirname_path_prefix())), 
  #                          #data_info = gsub("\\\\", "/", paste0(normalizePath(dirname_data_prefix()), slash(), input$data_info)), 
  #                          model_dir = gsub("\\\\", "/", normalizePath(dirname_model_dir())),
  #                          python_loc = gsub("\\\\", "/", normalizePath(dirname_python_loc())), 
  #                          log_dir = input$log_dir, 
  #                          num_classes = input$num_classes,
  #                          save_predictions = input$save_predictions,
  #                          architecture = input$architecture,
  #                          depth = input$depth, 
  #                          num_cores = input$num_cores,
  #                          top_n = input$top_n,
  #                          batch_size = input$batch_size,
  #                          output_name = input$output_name,
  #                          os=input$os
  #   )
  # })
  
  # shiny::observeEvent(input$runClassify, {
  #   do.call(classify, windows_input)
  # })

  
}

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
      shinyFiles::shinyFilesButton('data_info', "Image label file", title="Select the file containing your filenames and their associated labels.", multiple=FALSE),
      #shinyFiles::shinyDirButton('data_prefix', "Location of image label file", title="Select directory containing image label file (file with file names of images and their classification). When you see this label file in the lower half of the window, select the folder in the top half of the window."),
      #shiny::textOutput("data_info"),
      #shiny::textInput('data_info', "Name of image label file (in the directory you just selected)", value="image_labels.csv"),
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
      shiny::textInput("batch_size", "Batch size (must be a multiple of 16)", formals(classify)[["batch_size"]]),
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

# function that uses these
shiny::shinyApp(ui, server)

#--
# test windows
# server <- function(input, output, session) {
# 
#   # determine if Windows"
#   Windows <- TRUE
#   if(Sys.info()["sysname"] == "Windows"){
#     Windows <- TRUE
#   } else {
#     Windows <- FALSE
#   }
# 
#   slash <- reactive({ifelse(Windows, "\\", "/")})
#   #output$slash2 <- observeEvent({slash()})
#   output$slash2 <- renderText({slash()})
# 
# }
# ui <- fluidPage(
#     shiny::textOutput("slash")
# )
# shiny::shinyApp(ui, server)

# make a simple version
# library(shiny)
# txt_fun <- function(txt){return(txt)} # this will be more complicated
# server <- function(input, output, session) {
#   
#   txt <<- reactive({
#     input$txt
#   })
#   
#   shiny::observeEvent(input$runRun,{
#     txt_fun(txt())
#   })
#   
#   output$txt <- renderText({
#    txt <<- input$txt
#   })
#   
# }
# ui <- fluidPage(
#   shiny::textInput("txt", "enter text"),
#   shiny::actionButton("runFun", "Run Function")
# )
# shinyApp(ui, server)

# root <- "(C:)"
# root1 <- gsub("\\(", "", root)
# gsub("\\)", "", root1)
