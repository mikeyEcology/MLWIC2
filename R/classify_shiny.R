classify_shiny <- function(
  path_prefix = paste0(getwd(), "/images"), # absolute path to location of the images on your computer
  data_info = paste0(getwd(), "/image_labels.csv"), # csv with file names for each photo. See details
  model_dir = getwd(),
  save_predictions = "model_predictions.txt", # txt file where you want model output to go
  python_loc = "/anaconda3/bin/", # location of the python that Anacnoda uses on your machine
  os="Mac",
  num_classes = 28, # number of classes in model
  delimiter = ",", # this will be , for a csv.
  architecture = "resnet",
  depth = "18",
  top_n = "5",
  num_threads = 1,
  batch_size = 128,
  num_gpus = 2,
  log_dir = "trained_model"
  
){
  wd1 <- getwd() # the starting working directory
  
  # set these parameters before changing directory
  path_prefix = path_prefix
  data_info = data_info
  model_dir = model_dir
  
  # navigate to directory with trained model
  if(endsWith(model_dir, "/")){
    wd <- (paste0(model_dir, "trained_model"))
  } else {
    wd <- (paste0(model_dir, "/trained_model"))
  }
  
  
  # load in data_info and store it in the model_dir
  # lbls <- utils::read.csv(data_info, header=FALSE)
  # lbls[,1] <- as.character(lbls[,1])
  # utils::write.table(lbls, "data_info.csv", sep=",",
  #                    row.names=FALSE, col.names=FALSE)
  #file.copy(from=data_info, to=paste0(wd, "/data_info.csv"), header=FALSE)
  
  if(os=="Windows"){
    # deal with windows file format issues
    data_file <- read.table(data_info, header=FALSE, sep=",")
    output.file <- file("data_info.csv", "wb")
    write.table(data_file,
                file = output.file,
                append = TRUE,
                quote = FALSE,
                row.names = FALSE,
                col.names = FALSE,
                sep = ",")
    close(output.file)
    rm(output.file)
  } else {
    
    cpfile <- paste0("cp ", data_info, " ", wd, "/data_info.csv")
    system(cpfile)
  }
  
  # set depth
  if(architecture == "alexnet"){
    depth <- 8
  }
  if(architecture == "nin"){
    depth <- 16
  }
  if(architecture == "vgg"){
    depth <- 22
  }
  if(architecture == "googlenet"){
    depth <- 32
  }
  
  # set up code
  eval_py <- paste0(python_loc,
                    "python run.py eval --num_threads ", num_threads, 
                    " --architecture ", architecture,
                    " --depth ", depth,
                    " --log_dir ", log_dir,
                    " --snapshot_prefix ", log_dir,
                    " --path_prefix ", path_prefix,
                    " --batch_size ", batch_size, 
                    " --val_info ", data_info,
                    " --delimiter ", delimiter,
                    " --save_predictions ", save_predictions,
                    " --top_n ", top_n,
                    " --num_gpus ", num_gpus,
                    " --num_classes ", num_classes, "\n")
  
  # set directory using system
  # if(.Platform$OS.type == "unix") {
  #   system(paste0("cd ", wd))
  # } else {
  #   system(paste0(""))
  # }
  system(paste0("cd ", wd, "\n",
                eval_py))
  
  # run code - THIS WORKS!!
  toc <- Sys.time()
  system(paste0("cd ", wd, "\n", # set directory using system because it can't be done in shiny
                eval_py))
  tic <- Sys.time()
  runtime <- difftime(tic, toc, units="auto")
  
  # end function
  txt <- paste0("evaluation of images took ", runtime, " ", units(runtime), ". ",
                "The results are stored in ", model_dir, "trained_model/", save_predictions, ". ",
                "To view the results in a viewer-friendly format, please use the function make_output")
  print(txt)
  
  # return to previous working directory
  setwd(wd1)
  
}


# shiny
library(shiny)
server <- function(input, output) {
  
  # run classify
  observeEvent(input$runClassify, {
    classify_shiny(path_prefix = input$path_prefix,
              data_info = input$data_info,
              model_dir = input$model_dir)
  })
  
  # observeEvent(input$runClassify, {
  #   wd <- getwd()
  #   output$value <- renderPrint(wd)
  # })
}
# Define UI for miles per gallon app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("quantile"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    # sidebarPanel(
    #   selectInput("breaks", "Breaks:",
    #               seq(0.01, .99, by=0.01))
    # ), # this works with option 1
    
    sidebarPanel(
      textInput("path_prefix", "Path Prefix"),
      textInput("data_info", "Image Label Location"),
      textInput("model_dir", "Model Directory"),
      actionButton("runClassify", "Run Classify Function")
    ), # this works with option 2
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Plot of the requested variable against mpg ----
      #h3(textOutput("quant"))
      #h3(renderText(textOutput("quant")))
      #renderPrint("quant")
      #textOutput("value")
      
    )
  )
)

# function that uses these
shinyApp(ui, server)

# put in these vlues
#path prefix: /Users/mikeytabak/Desktop/APHIS/mtMoran_projects/MLWIC_dir/MLWIC_package/MLWIC_examples/MLWIC_examples/images
#image label location: /Users/mikeytabak/Desktop/APHIS/mtMoran_projects/MLWIC_dir/MLWIC_package/MLWIC_examples/MLWIC_examples/image_labels.csv
#model directory: /Users/mikeytabak/Desktop/APHIS/teton_projects/trained_model_20190610/fitted_model/
  #*** In model.py file, I commented out line 279: self.pretrained_loader.restore(sess, ckpt.model_checkpoint_path)