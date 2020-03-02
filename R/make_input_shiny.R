# shiny
server <- function(input, output, session) {
  
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
    }
  })
  # observe filename changes
  # shiny::observe({
  #   if(!is.null(filename_input_file)){
  #     print(filename_input_file())
  #     output$input_file <- shiny::renderText(filename_input_file())
  #   }
  # })
  
  
  
  #- run classify
  shiny::observeEvent(input$runMake_input, {
    # do this silly bit for gettin inpath to work
    inFile <- input$input_file
    if(is.integer(inFile)){
      return(NULL)
    } else{
      inPath <<- paste0(inFile$files$`0`, collapse="/")
    }
    make_input(
      #input_file = normalizePath(filename_input_file()),
      input_file = inPath,
      find_file_names = input$find_file_names,
      path_prefix = gsub("\\\\", "/", normalizePath(dirname_path_prefix())),
      image_file_suffixes = c(".jpg", ".JPG"),
      recursive = input$recursive,
      usingBuiltIn = input$usingBuiltIn, 
      model_type = input$model_type,
      images_classified = input$images_classified,
      find_class_IDs = input$find_class_IDs,
      trainTest = input$train_test, 
      file_prefix = "",
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
      shiny::selectInput("find_file_names", "Do you want MLWIC2 to find the names of your image files? 
                         This means that you will not be providing an Image label file", c(
                           "Yes" = "TRUE",
                           "No" = "FALSE"
                         )),
      shiny::helpText("Only select Image directory button if you want MLWIC2 to find your file names."),
      shinyFiles::shinyDirButton('path_prefix', 'Image directory', title='Select the parent directory where images are stored'),
      shiny::selectInput("recursive", "Are the images all directly in your Image directory? Selecting Yes means that
                         you do not have images stored in sub-folders within this folder", c(
                           "No" = "TRUE",
                           "Yes" = "FALSE" # yes is false because recusrive is false
                         )),
      shiny::selectInput("usingBuiltIn", "Are you using one of the models that came with MLWIC2? 
                         If you are using a model that you trained, select No", c(
                           "Yes" = "TRUE", 
                           "No" = "FALSE"
                         )),
      shiny::selectInput("model_type", "Which model type are you using? If you trained your own model, ignore", c(
        "Species model" = "species_model", 
        "Empty/Animal model" = "empty_animal"
      )),
      shiny::selectInput("images_classified", "Have your images already been classified? (you know what species is in the images)", c(
        "No" = "FALSE",
        "Yes" = "TRUE"
      )),
      shiny::selectInput("find_class_IDs", "Do you want MLWIC2 to find the class_IDs for each image? 
                         Selecting No means that (if your images are classified) you're providing an input file with class_IDs that match
                         the values found in this table (https://github.com/mikeyEcology/MLWIC2/blob/master/speciesID.csv)", c(
                           "No" = "FALSE",
                           "Yes" = "TRUE"
      )),
      shiny::selectInput("train_test", "Do you want MLWIC2 to make separate training and testing input files?
                         Select no unless you are trainig a model.", c(
                           "No" = "FALSE",
                           "Yes" = "TRUE"
      )),
      shiny::textInput("propTrain", "Proportion of images for training. Unless you're setting up a training/testing dataset, ignore", formals(classify)[["propTrain"]]),
      shiny::actionButton("runMake_input", "Make an input file")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server)


# example 
fun1 <- function(x){
  y <- read.csv(x, header=F)
  return(head(y))
  
  colnames(y) <- c("filename", "class_ID")
  wd <- "/Users/mikeytabak/Desktop/APHIS/teton_projects/trained_model_20190610/R_package/MLWIC2"
  file(paste0(wd, "/", "out_file.csv"))
  write.table(y, row.names = FALSE, col.names = FALSE, file = output.file, quote = FALSE,append = TRUE,sep = ",")
  close(output.file)
  rm(output.file) 
  }

# simple shiny code to read find a file and read it in. 
server <- function(input, output, session) {
  
  # base directory for fileChoose
  volumes = shinyFiles::getVolumes()
  # input_file
  shinyFiles::shinyFileChoose(input, "input_file", roots=volumes, session=session, filetypes=c('csv'))
  #filename_input_file <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$input_file)[length(shinyFiles::parseFilePaths(volumes, input$input_file))]})
  filename_input_file <- shiny::reactive({shinyFiles::parseFilePaths(volumes, input$input_file)})
  
  # observe filename changes
  # shiny::observe({
  #   if(!is.integer(filename_input_file)){
  #     print(filename_input_file())
  #     output$input_file <- shiny::renderText(filename_input_file())
  #   }
  # })
  
  # input_file <<- renderPrint({
  #   if (is.integer(input$input_file)) {
  #     cat("No files have been selected (shinyFileChoose)")
  #   } else {
  #     parseFilePaths(volumes, input$input_file)
  #   }
  # })
  
  # run the function
  # shiny::observeEvent(input$runFUN, {
  #   #fun1(normalizePath(filename_input_file()))
  #   #fun1(parseFilePaths(volumes, input$input_file))
  #   fun1(input$input_file)
  # })
  
  # shiny::observeEvent(input$runFUN, {
  #   if (is.integer(filename_input_file)) {
  #     cat("No files have been selected (shinyFileChoose)")
  #   } else {
  #     #fun1(parseFilePaths(volumes, input$input_file))
  #     fun1(filename_input_file)
  #   }
  # })
  
  # shiny::observeEvent(input$runFUN, {
  #   inFile <<- input$input_file
  #   if (is.integer(input$input_file)) {
  #     cat("No files have been selected (shinyFileChoose)")
  #   } else {
  #     #fun1(parseFilePaths(volumes, input$input_file))
  #     #fun1(input$input_file$datapath)
  #     fun1(inFile$datapath)
  #   }
  # })
  
  # upload <- reactive({
  #   inFile <- input$input_file
  #   if(is.null(inFile)){
  #     return(NULL)
  #   } else{
  #     inPath <<- paste0(inFile$files$`0`, collapse="/")
  #   }
  # })

  
  #*** this works kinda ***
  shiny::observeEvent(input$runFUN, {
    inFile <- input$input_file
    if(is.integer(inFile)){
      return(NULL)
    } else{
      inPath <- paste0(inFile$files$`0`, collapse="/")
    }
    fun1(inPath)
  })
  
  
  
}
ui <- shiny::fluidPage(
  
  # App title ----
  shiny::titlePanel("test"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shinyFiles::shinyFilesButton('input_file', "file", title="Select a csv", multiple=FALSE),
      shiny::actionButton("runFUN", "run function")
    ), # this works with option 2
    
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
    )
  )
)

shiny::shinyApp(ui, server)


# example from shinyFiles page

server <- shinyServer(function(input, output, session) {
  volumes <- c(Home = fs::path_home(), "R Installation" = R.home(), getVolumes()())
  shinyFileChoose(input, "file", roots = volumes, session = session)
  shinyDirChoose(input, "directory", roots = volumes, session = session, restrictions = system.file(package = "base"))
  shinyFileSave(input, "save", roots = volumes, session = session, restrictions = system.file(package = "base"))
  
  ## print to console to see how the value of the shinyFiles 
  ## button changes after clicking and selection
  observe({
    cat("\ninput$file value:\n\n")
    print(input$file)
  })
  
  observe({
    cat("\ninput$directory value:\n\n")
    print(input$directory)
  })
  
  observe({
    cat("\ninput$save value:\n\n")
    print(input$save)
  })
  
  ## print to browser
  output$filepaths <- renderPrint({
    if (is.integer(input$file)) {
      cat("No files have been selected (shinyFileChoose)")
    } else {
      parseFilePaths(volumes, input$file)
    }
  })
  
  output$directorypath <- renderPrint({
    if (is.integer(input$directory)) {
      cat("No directory has been selected (shinyDirChoose)")
    } else {
      parseDirPath(volumes, input$directory)
    }
  })
  
  output$savefile <- renderPrint({
    if (is.integer(input$file)) {
      cat("No file-save path has been set (shinyFileSave)")
    } else {
      parseSavePath(volumes, input$save)
    }
  })
})

ui <- shinyUI(pageWithSidebar(
  headerPanel(
    "Selections with shinyFiles",
    "shinyFiles example"
  ),
  sidebarPanel(
    img(src = "logo.png", style = "float: left; width: 120px; margin-right: 10px; margin-top: 5px"),
    tags$p("The following buttons will expose the users home directory,\n
           R installation directory and other available volumes. To showcase\n 
           the restriction feature the base package has been hidden."),
    tags$p("As each button is used multiple times, the last location is\n
           remembered, as well as any other states. Each button has its own\n
           memory."),
    tags$hr(),
    shinyFilesButton("file", "File select", "Please select a file", multiple = TRUE),
    tags$p(),
    tags$p('The file selection button allows the user to select one or several 
           files and get their absolute position communicated back to the shiny
           server. In this example the button has been set to single-file mode 
           and the default path has been set to the users home directory.'),
    tags$hr(),
    shinyDirButton("directory", "Folder select", "Please select a folder"),
    tags$p(),
    tags$p("This button lets the user navigate the file system and select a\n
           folder. The absolute path of the selected folder is then sent\n
           back to the server. While only folders can be selected, it is\n
           possible to get an overview of the content beforehand. \n
           Furthermore it is permission aware and warns if a folder with \n
           missing write permissions is selected. Lastly it is possible to\n
           create folders on the fly"),
    tags$hr(),
    shinySaveButton("save", "Save file", "Save file as...", filetype = list(text = "txt", picture = c("jpeg", "jpg"))),
    tags$p(),
    tags$p('The last type of button is the save button which allows the user
           to navigate to a position in the filesystem and specify the name
           of a new file to be sent back to the server. As above, write 
           permissions are communicated and folders can be created. It is
           possible to specify a range of different filetypes that the user
           can choose between. In this example it is "text" and "picture"')
    ),
  mainPanel(
    tags$h4("The output of a file selection"),
    tags$p(HTML("When one or several files are chosen the result is made \n
                available to the shinyServer instance. In order for it to get the\n
                formatting expected of a filepath it must first be fed into\n
                <code>parseFilePaths()</code> after which the output matches the formatting of\n
                that returned by shiny's own fileInput widget.")),
    verbatimTextOutput("filepaths"),
    tags$hr(),
    tags$h4("The output of a folder selection"),
    tags$p(HTML("When a folder is selected the position of the folder is sent to \n
                the server and can be formatted with <code>parseDirPath()</code> to reflect a\n
                standard path string as returned by e.g. <code>choose.dir()</code> on windows\n
                systems.")),
    verbatimTextOutput("directorypath"),
    tags$hr(),
    tags$h4("The output of a file save"),
    tags$p(HTML('When a file is "saved" the name, path, and type are sent back to
                the server and formatted with <code>parseSavePath()</code>. The 
                format after parsing is very similar to a file choice, except
                size information is omitted (often the file doesn\'t exist yet)
                and type is now available (provided that filetype information has
                been sent from the server).')),
    verbatimTextOutput("savefile")
                )
    ))
shiny::shinyApp(ui, server)  
