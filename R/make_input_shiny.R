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
  # input_file
  shinyFiles::shinyFileChoose(input, "input_file", roots=volumes, session=session, filetypes=c('txt', 'csv'))
  filename_input_file <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$input_file)[length(shinyFiles::parseFilePaths(volumes, input$input_file))]})
  #filename_input_file <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$input_file)})
  # path_prefix
  shinyFiles::shinyDirChoose(input, 'path_prefix', roots=volumes, session=session)
  dirname_path_prefix <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$path_prefix)})
  # Observe path_prefix changes
  shiny::observe({
    if(!is.null(dirname_path_prefix)){
      print(dirname_path_prefix())
      output$path_prefix <- shiny::renderText(dirname_path_prefix())
    } else{
      output$path_prefix <- getwd()
    }
  })
  # output_dir
  shinyFiles::shinyDirChoose(input, 'output_dir', roots=volumes, session=session)
  dirname_output_dir <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$output_dir)})
  # Observe output_dir changes
  shiny::observe({
    if(!is.null(dirname_output_dir)){
      print(dirname_output_dir())
      output$output_dir <- shiny::renderText(dirname_output_dir())
    } else{
      output$output_dir <- getwd()
    }
  })
  
  
  #- run classify
  shiny::observeEvent(input$runMake_input, {
    showModal(modalDialog("Making input file(s). You may press dismiss at any time. Check your R console for more information. A warning message about invalid argument type is expected."))
    # dealing with null path prefix
    # if(is.null(dirname_path_prefix)){
    #   path_prefix <- getwd()
    # } else{
    #   print(dirname_path_prefix())
    #   #path_prefix1 <- shiny::renderText(dirname_path_prefix())
    #   path_prefix <- gsub("\\\\", "/", normalizePath(dirname_path_prefix()))
    # }
    # do this to read file in shiny
    inFile <<- input$input_file
    if(is.integer(inFile)){
      return(NULL)
    } else{
      # on Windows deal with  issuefinding the right drive
      if(os == "Windows"){
        root <- inFile$root
        root1 <- gsub("\\(", "", root)
        root2 <- gsub("\\)", "", root1) # this gives [Drive]:
        inFile_collapse <- paste0(root2, paste0(inFile$files$`0`, collapse="/"))
      } else { # on not windows, we don't have to deal with this
        inFile_collapse <- paste0(inFile$files$`0`, collapse="/")
      }
    }
    make_input(
      #input_file = normalizePath(filename_input_file()),
      input_file = inFile_collapse,
      find_file_names = input$find_file_names,
      path_prefix = gsub("\\\\", "/", normalizePath(dirname_path_prefix())),
      #path_prefix = path_prefix,
      output_dir = gsub("\\\\", "/", normalizePath(dirname_output_dir())),
      option = input$option,
      image_file_suffixes = c(".jpg", ".JPG"),
      recursive = input$recursive,
      usingBuiltIn = input$usingBuiltIn, 
      model_type = input$model_type,
      images_classified = input$images_classified,
      find_class_IDs = input$find_class_IDs,
      trainTest = input$train_test, 
      file_prefix = "",
      shiny=TRUE,
      propTrain = input$propTrain
    )
  })
  
}

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
      
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server)


# # example
# fun1 <- function(x){
#   y <- read.csv(x, header=F)
#   return(head(y))
#
#   colnames(y) <- c("filename", "class_ID")
#   wd <- "/Users/mikeytabak/Desktop/APHIS/teton_projects/trained_model_20190610/R_package/MLWIC2"
#   output.file <- file(paste0(wd, "/", "out_file.csv"))
#   write.table(y, row.names = FALSE, col.names = FALSE, file = output.file, quote = FALSE,append = TRUE,sep = ",")
#   close(output.file)
#   rm(output.file)
# }
#
# # just write a csv
# fun1 <- function(x){
#   wd <- getwd()
#   y <- mtcars
#   output.file <- file(paste0(wd, "/", "out_file.csv"))
#   write.table(y, row.names = FALSE, col.names = FALSE, file = output.file, quote = FALSE,append = TRUE,sep = ",")
#   close(output.file)
#   rm(output.file)
#
# }

# # simple shiny code to read find a file and read it in.
# server <- function(input, output, session) {
#
#   # base directory for fileChoose
#   volumes = shinyFiles::getVolumes()
#   # input_file
#   shinyFiles::shinyFileChoose(input, "input_file", roots=volumes, session=session, filetypes=c('csv'))
#   #filename_input_file <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$input_file)[length(shinyFiles::parseFilePaths(volumes, input$input_file))]})
#   filename_input_file <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$input_file)})
#
#   # observe filename changes
#   # shiny::observe({
#   #   if(!is.integer(filename_input_file)){
#   #     print(filename_input_file())
#   #     output$input_file <- shiny::renderText(filename_input_file())
#   #   }
#   # })
#
#   # input_file <<- renderPrint({
#   #   if (is.integer(input$input_file)) {
#   #     cat("No files have been selected (shinyFileChoose)")
#   #   } else {
#   #     parseFilePaths(volumes, input$input_file)
#   #   }
#   # })
#
#   # run the function
#   # shiny::observeEvent(input$runFUN, {
#   #   #fun1(normalizePath(filename_input_file()))
#   #   #fun1(parseFilePaths(volumes, input$input_file))
#   #   fun1(input$input_file)
#   # })
#
#   # shiny::observeEvent(input$runFUN, {
#   #   if (is.integer(filename_input_file)) {
#   #     cat("No files have been selected (shinyFileChoose)")
#   #   } else {
#   #     #fun1(parseFilePaths(volumes, input$input_file))
#   #     fun1(filename_input_file)
#   #   }
#   # })
#
#   # shiny::observeEvent(input$runFUN, {
#   #   inFile <<- input$input_file
#   #   if (is.integer(input$input_file)) {
#   #     cat("No files have been selected (shinyFileChoose)")
#   #   } else {
#   #     #fun1(parseFilePaths(volumes, input$input_file))
#   #     #fun1(input$input_file$datapath)
#   #     fun1(inFile$datapath)
#   #   }
#   # })
#
#   # upload <- reactive({
#   #   inFile <- input$input_file
#   #   if(is.null(inFile)){
#   #     return(NULL)
#   #   } else{
#   #     inPath <<- paste0(inFile$files$`0`, collapse="/")
#   #   }
#   # })
#
#
#   #*** this works kinda ***
#   shiny::observeEvent(input$runFUN, {
#     inFile <- input$input_file
#     if(is.integer(inFile)){
#       return(NULL)
#     } else{
#       inPath <- paste0(inFile$files$`0`, collapse="/")
#     }
#     fun1(inPath)
#   })
#
#
# }
# ui <- shiny::fluidPage(
#
#   # App title ----
#   shiny::titlePanel("test"),
#
#   # Sidebar layout with input and output definitions ----
#   shiny::sidebarLayout(
#     shiny::sidebarPanel(
#       shinyFiles::shinyFilesButton('input_file', "file", title="Select a csv", multiple=FALSE),
#       shiny::actionButton("runFUN", "run function")
#     ), # this works with option 2
#
#
#     # Main panel for displaying outputs ----
#     shiny::mainPanel(
#
#     )
#   )
# )
#
# shiny::shinyApp(ui, server)
