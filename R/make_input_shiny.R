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
  
  
  #- run make_input
  shiny::observeEvent(input$runMake_input, {
    showModal(modalDialog("Making input file(s). You may press dismiss at any time. Check your R console for more information."))
    # dealing with null path prefix
    # if(is.null(dirname_path_prefix)){
    #   path_prefix <- getwd()
    # } else{
    #   print(dirname_path_prefix())
    #   #path_prefix1 <- shiny::renderText(dirname_path_prefix())
    #   path_prefix <- gsub("\\\\", "/", normalizePath(dirname_path_prefix()))
    # }
    # do this to read file in shiny
    inFile <- input$input_file
    if(is.integer(inFile)){
      #return(NULL)
      inFile_collapse <- NULL
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
      option = input$option,
      find_file_names = input$find_file_names,
      path_prefix = gsub("\\\\", "/", normalizePath(dirname_path_prefix())),
      #path_prefix = path_prefix,
      output_dir = gsub("\\\\", "/", normalizePath(dirname_output_dir())),
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
      shiny::selectInput("option", "Which Option number do you want to use? See description to the right", c(
        "1" = "1",
        "2" = "2",
        "3" = "3",
        "4" = "4",
        "5" = "5"
      )),
      shiny::helpText("If you are providing a csv containing image file names (you are using any Option besides Option 4), select it using the `Image label file` button. Otherwise skip this button."),
      shinyFiles::shinyFilesButton('input_file', "Image label file", title="Select a csv containing file names of images and their classification", multiple=FALSE),
      shinyFiles::shinyDirButton('output_dir', "Directory to store Input file", title="Select the directory where you want to store your input file. Your MLWIC2_helper_files folder would be a good place for this."),
      shiny::helpText("Only select `Image directory` button if you are using Option 4."),
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      shiny::selectInput("recursive", "Are the images all directly in your Image directory? Selecting Yes means that
                         you do not have images stored in sub-folders within this folder. Only relevant for Option 4.", c(
                           "No" = "TRUE",
                           "Yes" = "FALSE" # yes is false because recusrive is false
                         )),
      shiny::selectInput("model_type", "Which model type are you using? If you trained your own model, ignore", c(
        "Species model" = "species_model", 
        "Empty/Animal model" = "empty_animal"
      )),
      shiny::helpText("Only set training proportion if you are using option 5."),
      shiny::textInput("propTrain", "Proportion of images for training.", formals(make_input)[["propTrain"]]),
      shiny::actionButton("runMake_input", "Make an input file")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      shiny::helpText("Use these as a guide as you fill in the number for `Option`:",
        shiny::br(), shiny::br(),
        "Option 1: If you have labels for your images and you want to test the model on your images, you need to have an `Image label file` csv that has at last two columns and one of these must be 'filename' and the other must be 'class_ID'. The 'class_ID' column must contain the number associated with each class. ",
                      shiny::br(),
                      "Option 2: This is the same as Option 1, except instead of having a number for each class, you have a column called `class` containing your classifications as words (e.g., 'dog' or 'cattle', 'empty'), the function will find the appropriate `class_ID` associated with these words.",
                      shiny::br(),
                      "Option 3: If you do not have your images classified, but you have all of the filenames for the images you want to classify, you can have an `Image label file` csv with a column called 'filename' and whatever other columns you would like.",
                      shiny::br(),
                      "Option 4: MLWIC2 will find the filenames of all of your images and create your input file. For this option, you need to specify your `Image directory` which is the parent directory of your images. ",
                      shiny::br(),
                      "Option 5: If you are planning to train a model, you will want training and testing sets of images. This function will set up these files also. You will want to set the proportion of training images (0.9 is the default).",
        shiny::br(), shiny::br(),
        "This function is create a directory called `MLWIC2_inputFile_dir` inside of the directory you selected to store your input file. See R console for exact location of your input file."
        )
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
