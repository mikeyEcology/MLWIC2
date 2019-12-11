# shiny
server <- function(input, output) {
  shinyDirChoose(
    input,
    'dir',
    roots = c(home = '~'),
    filetypes = c('', 'txt', 'bigWig', "tsv", "csv", "bw", "JPG")
  )
  # run classify
  shiny::observeEvent(input$runClassify, {
    classify(#path_prefix = input$path_prefix,
      path_prefix = path,
      data_info = input$data_info,
      model_dir = input$model_dir,
      save_predictions = input$save_predictions,
      python_loc = input$python_loc,
      num_classes = input$num_classes,
      architecture = input$architecture,
      depth = input$depth,
      top_n = input$top_n,
      batch_size = input$batch_size,
      log_dir= input$log_dir
    )
  })
  
  # file finder stuff
  dir <- reactive(input$dir)
  output$dir <- renderText({  # use renderText instead of renderPrint
    parseDirPath(c(home = '~'), dir())
  })
  
  observeEvent(ignoreNULL = TRUE,
               eventExpr = {
                 input$dir
               },
               handlerExpr = {
                 req(is.list(input$dir))
                 home <- normalizePath("~")
                 global$datapath <-
                   file.path(home, paste(unlist(dir()$path[-1]), collapse = .Platform$file.sep))
               })
  
  # org stuff
  shiny::observeEvent(input$runClassify, {
    make_output(
      output_location = input$model_dir,
      model_dir= input$model_dir,
      saved_predictions = input$save_predictions,
      top_n = input$top_n
    )
  })
  
  # observeEvent(input$runClassify, {
  #   wd <- getwd()
  #   output$value <- renderPrint(wd)
  # })
}
# Define UI for miles per gallon app ----
ui <- fluidPage(
  
  # App title ----
  shiny::titlePanel("Classify images using MLWIC2"),
  
  # Sidebar layout with input and output definitions ----
  shiny::sidebarLayout(
    
    # Sidebar panel for inputs ----
    # sidebarPanel(
    #   selectInput("breaks", "Breaks:",
    #               seq(0.01, .99, by=0.01))
    # ), # this works with option 1
    
    shiny::sidebarPanel(
      #textInput("path_prefix", "Path Prefix"),
      shinyDirButton("dir", "Location of images", "Select"),
      verbatimTextOutput("dir", placeholder = TRUE) ,
      textInput("data_info", "Image Label Location"),
      textInput("model_dir", "Model Directory"),
      textInput("python_loc", "Location of Python on your computer"),
      textInput("num_classes", "Number of classes in trained model (BILB = If using Built In model, you can Leave these categories Blank)"),
      textInput("save_predictions", "Name of text file to save predictions (BILB; must end in .txt)"),
      textInput("log_dir", "Directory name of trained model (BILB)"),
      textInput("architecture", "CNN Architecture (BILB)"),
      textInput("depth", "CNN Depth (BILB)"),
      textInput("top_n", "Number of guesses to save (BILB)"),
      textInput("batch_size", "Batch size (BILB)"),
      actionButton("runClassify", "Run Classify Function")
    ), # this works with option 2
    
    # Main panel for displaying outputs ----
    shiny::mainPanel(
      
      # Output: Plot of the requested variable against mpg ----
      #h3(textOutput("quant"))
      #h3(renderText(textOutput("quant")))
      #renderPrint("quant")
      #textOutput("value")
      
    )
  )
)

# function that uses these
shiny::shinyApp(ui, server) # not working for folders

# put in these vlues
#path prefix: /Users/mikeytabak/Desktop/APHIS/mtMoran_projects/MLWIC_dir/MLWIC_package/MLWIC_examples/MLWIC_examples/images
#image label location: /Users/mikeytabak/Desktop/APHIS/mtMoran_projects/MLWIC_dir/MLWIC_package/MLWIC_examples/MLWIC_examples/image_labels.csv
#model directory: /Users/mikeytabak/Desktop/APHIS/teton_projects/trained_model_20190610/fitted_model/
#*** In model.py file, I commented out line 279: self.pretrained_loader.restore(sess, ckpt.model_checkpoint_path)

# test folders:
library(shiny)
library(shinyFiles)

# try again
# Define UI for application that draws a histogram
ui <- fluidPage( # Application title
  mainPanel(
    shinyDirButton("dir", "Input directory", "Upload"),
    verbatimTextOutput("dir", placeholder = TRUE)  # added a placeholder
  ))

server <- function(input, output) {
  shinyDirChoose(
    input,
    'dir',
    roots = c(home = '~')
  )
  
  dir <- reactive(input$dir)
  output$dir <- renderText({  # use renderText instead of renderPrint
    parseDirPath(c(home = '~'), dir())
  })
  
  observeEvent(ignoreNULL = TRUE,
               eventExpr = {
                 input$dir
               },
               handlerExpr = {
                 req(is.list(input$dir))
                 home <- normalizePath("~")
                 global$datapath <-
                   file.path(home, paste(unlist(dir()$path[-1]), collapse = .Platform$file.sep))
               })
}
# Run the application
shinyApp(ui = ui, server = server)

# another option
shinyApp(
  shinyUI(bootstrapPage(
    shinyDirButton('folder', 'Select a folder', 'Please select a folder', FALSE)
  )),
  
  shinyServer(function(input, output) {
    shinyDirChoose(input, 'folder', roots=c(home = '~'), filetypes=c('', 'txt'))
    
    observe({
      print(input$folder)
    })
  })
)
# rewrite this so it makes sense
ui <- fluidPage(
  shinyDirButton('folder', 'Select a folder', 'Please select a folder', FALSE),
  #verbatimTextOutput("folder", placeholder = TRUE) 
  textOutput("folder")
)
server <- function(input, output){
  volumes = getVolumes()
  observe({
    shinyDirChoose(input, 'folder', roots=volumes, filetypes=c('', 'txt'))
    dirname <- reactive({parseDirPath(volumes, input$folder)})
    print(input$folder)
  })
  observe({
    if(!is.null(dirname)){
      print(dirname())
      output$folder <- renderText(dirname())
    }
  })
}
shinyApp(ui=ui, server=server)

# another option
ui <- fluidPage(
  shinyDirButton("folder1", "Choose a folder" ,
                 title = "Please select a folder:", 
                 buttonType = "default", class = NULL),
  verbatimTextOutput("folder1", placeholder = TRUE) ,
  
  textOutput("folder1")     
)
server <- function(input,output,session){
  
  volumes = getVolumes()
  observe({  
    shinyDirChoose(input, "folder1", root = volumes, session = session)
    
  })
}
shinyApp(ui = ui, server = server)



printFun <- function(x){
  print(paste0(x))
}

# working version
# UI 
ui <- fluidPage(
  shinyDirButton('path_prefix', 'Select a directory', title='Select a directory'),
  textOutput('path_prefix'),
  textInput("path2", "Paste a path here"),
  actionButton("run", "run test")
)
# Server
server <- function(input, output, session) {
  volumes <- c(home = "")
  shinyDirChoose(input, 'path_prefix', roots=volumes, session=session)
  dirname_path_prefix <- reactive({parseDirPath(volumes, input$path_prefix)})
  
  # Observe input dir
  observe({
    if(!is.null(dirname_path_prefix)){
      print(dirname_path_prefix())
      output$path_prefix <- renderText(dirname_path_prefix())
    }
  })
  
  observeEvent(input$run, {
    printFun(dirname_path_prefix())
    printFun(input$path2)
  })
  
}
shinyApp(ui = ui, server = server)

# works to have two shinyDirButtons
# UI 
ui <- fluidPage(
  shinyDirButton('path_prefix', 'Select a directory', title='Select a directory'),
  textOutput('path_prefix'),
  shinyDirButton('path2', 'Select a directory', title='Select a directory'),
  textOutput('path2'),
  shinyFilesButton('data_info', "data file", title="select file", multiple=FALSE),
  textOutput("data_info"),
  actionButton("run", "run test")
)
# Server
server <- function(input, output, session) {
  volumes <- c(home = "")
  shinyDirChoose(input, 'path_prefix', roots=volumes, session=session)
  dirname_path_prefix <- reactive({parseDirPath(volumes, input$path_prefix)})
  # Observe input dir
  observe({
    if(!is.null(dirname_path_prefix)){
      print(dirname_path_prefix())
      output$path_prefix <- renderText(dirname_path_prefix())
    }
  })
  
  shinyDirChoose(input, 'path2', roots=volumes, session=session)
  dirname_path2 <- reactive({parseDirPath(volumes, input$path2)})
  # Observe input dir
  observe({
    if(!is.null(dirname_path2)){
      print(dirname_path2())
      output$path_prefix <- renderText(dirname_path2())
    }
  })
  
  # data info file
   shinyFileChoose(input, "data_info", roots=volumes, session=session)
   filename_data_info <- reactive({parseFilePaths(volumes, input$data_info)[length(parseFilePaths(volumes, input$data_info))]})
   observeEvent(input$data_info, {
     filename <- parseFilePaths(volumes, input$data_info)
     output$data_info <- renderText(filename$datapath)
   })
   # filename <- reactive({parseFilePaths(volumes, input$data_info)})
   # if(!is.null(filename())){
   #   output$data_info <- renderText(filename())
   # }


   #output$data_info <- renderText(inFile)
     
  
  observeEvent(input$run, {
    printFun(dirname_path_prefix())
    printFun(dirname_path2())
    printFun(filename_data_info())
  })
  
}
shinyApp(ui = ui, server = server)


# file extract example from ?
## Not run: 
ui <- fluidPage(
  shinyFilesButton('files', 'File select', 'Please select a file', FALSE),
  verbatimTextOutput('rawInputValue'),
  verbatimTextOutput('filepaths'),
  actionButton("run", "run test")
)
server <- function(input, output) {
  roots = c(wd='.')
  shinyFileChoose(input, 'files', roots=roots, filetypes=c('', 'txt'))
  output$rawInputValue <- renderPrint({str(input$files)})
  output$filepaths <- renderPrint({parseFilePaths(roots, input$files)})
  filename <- reactive({parseDirPath(roots, input$files)})
  observeEvent(input$run{
    printFun(filename())
  })
  
}

shinyApp(ui = ui, server = server)



# simple example of function
printFun <- function(a = 1, b =2, c =3, d = 4){
  printVal <- paste0(
    "one = ", a, "\n",
    "two = ", b, "\n",
    "three = ", c, "\n",
    "four = ", d, "\n"
  )
  cat(printVal)
}
printFun <- function(a, b, c, d){
  useDef <- function(a,d) ifelse(isTruthy(a), a,d) 
  printVal <- paste0(
    "one = ", useDef(a,1), "\n",
    "two = ",useDef(b,2), "\n",
    "three = ", useDef(c,3), "\n",
    "four = ", useDef(d,4), "\n"
  )
  cat(printVal)
}
# ui function
ui <- fluidPage(
  textInput("a", "a value"),
  textInput("b", "b value"),
  textInput("c", "c value"),
  textInput("d", "d value"),
  actionButton("runFun", "run function")
)
server <- function(input, output){
  observeEvent(input$runFun, {
    printFun(
      a=input$a,
      b=input$b,
      c=input$c,
      d=input$d
    )
  })
}
server <- function(input, output){
  observeEvent(input$runFun, {
    vals <- Map(function(x) input[[x]], c("a","b","c","d"))
    vals <- Map(as.numeric, vals)
    vals <- Filter(function(x) !is.na(x), vals)
    do.call("printFun", vals)
  })
}
ui <- fluidPage(
  textInput("a", "a value", value=formals(printFun)[["a"]]),
  textInput("b", "b value", value=formals(printFun)[["b"]]),
  textInput("c", "c value", value=formals(printFun)[["c"]]),
  textInput("d", "d value", value=formals(printFun)[["d"]]),
  actionButton("runFun", "run function")
)
shinyApp(ui = ui, server = server)

