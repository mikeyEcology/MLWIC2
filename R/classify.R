#' Classify images using the trained model
#'
#' \code{classify} predicts the species in each image. 
#' This function uses absolute paths, but if you are unfamilliar with this
#' process, you can put all of your images, the image label csv ("data_info") and the trained_model folder that you
#' downloaded following the directions at https://github.com/mikeyEcology/MLWIC2 into one directory on
#' your computer. Then set your working directory to this location and the function will find the
#' absolute paths for you. If you trained a model using \code{train},
#' this function can also be used to evalute images using the model developed by
#' \code{train} by specifying the \code{log_dir} of the trained model. If this is your first time using
#' this function, you should see additional documentation at https://github.com/mikeyEcology/MLWIC2 .
#'
#' @param path_prefix Absolute path to location of the images on your computer (or computing cluster).
#'  All images must be stored in one folder.
#' @param data_info Name of a csv containing the file names of each image (including absolute path).
#'  It is recommended that you use the \code{make_input} function to make this \code{data_info} file
#'  in the proper format. See \code{speciesID} for the numbers (if using the built in model) of each
#'  species. If you do not know the species in the image, put a zero in each row of column 2.
#'  If you choose to make this file on your own: This file must have Unix linebreaks!
#'  This file must have only two columns and no headers. The first column must be the file name of the image
#'  The second column can be the number corresponding to the species or group in the image.
#' @param save_predictions File name where model predictions will be stored.
#'  You should not need to change this parameter.
#'  After running this function, you will run \code{make_output} to
#'  make the output in a more viewer friendly format
#' @param python_loc The location of python on your machine.
#' @param os the operating system you are using. If you are using windows, set this to
#'  "Windows", otherwise leave as default
#' @param num_classes The number of classes in your model. If you are using
#'  the built in model, the number is `59`.
#' @param delimiter this will be a `,` for a csv.
#' @param log_dir If you trained a model with \code{train}, this
#'  will be the log_directory that you specified when using that function.
#'  If you are using the built in model, the default is appropriate.
#'  @param architecture the architecture of the deep neural network (DNN). Resnet-18 is the default.
#'  Options are c("alexnet", "densenet", "googlenet", "nin", "resnet", "vgg").
#'  If you are using the trained model that comes with MLWIC, use resnet 18 (the default).
#'  If you trained a model using a different architechture, you need to specify this same architechture and depth
#'  that you used for training.
#' @param depth the number of layers in the DNN. If you are using the built in model, do not adjust this parameter.
#'  If you are using a model that you trained, use the same architecture and depth as that model.
#' @param top_n the number of guesses you want the model to make (how many species do you want to
#'  see the confidence for?). This number must be less than or equal to `num_classes`.
#' @param model_dir Absolute path to the location where you stored the trained folder
#'  that you downloaded from github.
#' @param batch_size The number of images for the model to evaluate in each batch. Larger numbers will run faster
#' @param make_output logical. Do you want the package to create a nice output file with column headers
#' @param output_name Desired name of the output file. It must end in `.csv`
#' @export
classify <- function(
  path_prefix = paste0(getwd(), "/images"), # absolute path to location of the images on your computer
  data_info = paste0(getwd(), "/image_labels.csv"), # csv with file names for each photo. See details
  model_dir = getwd(),
  save_predictions = "model_predictions.txt", # txt file where you want model output to go
  python_loc = "/anaconda3/bin/", # location of the python that Anacnoda uses on your machine
  os="Mac",
  num_classes = 59, # number of classes in model
  delimiter = ",", # this will be , for a csv.
  architecture = "resnet",
  depth = "18",
  top_n = 5,
  num_threads = 1,
  batch_size = 128,
  num_gpus = 2,
  log_dir = "trained_model",
  make_output=TRUE,
  output_location=getwd(),
  output_name = "MLWIC2_output.csv",
  shiny=FALSE,
  print_cmd = FALSE
  
){

  wd1 <- getwd() # the starting working directory
  
  # set these parameters before changing directory
  path_prefix = path_prefix
  data_info = data_info
  model_dir = model_dir


  # navigate to directory with trained model
  # if(endsWith(model_dir, "/")){
  #   setwd(paste0(model_dir, "log_dir"))
  # } else {
  #   setwd(paste0(model_dir, "/log_dir"))
  # }
  # wd <- getwd()
  
  # navigate to directory with trained model
  if(endsWith(model_dir, "/")){
    wd <- (paste0(model_dir, log_dir))
  } else {
    wd <- (paste0(model_dir, "/", log_dir))
  }
  if(shiny==FALSE){
    setwd(wd)
  }
  
  # add a / to the end of python directory if applicable
  python_loc <- ifelse(endsWith(python_loc, "/"), python_loc, paste0(python_loc, "/"))

  # test if tensorflow is installed
  if(print_cmd == FALSE){
    sink("MLWIC2_test_tf.py")
    cat("import tensorflow as tf")
    cat("\n")
    cat("print('Tensorflow is installed')")
    sink()
    test_tf <- paste0(python_loc, "python MLWIC2_test_tf.py")
    test_result <- system(test_tf, intern=TRUE, ignore.stderr = TRUE)
    if(test_result == 'Tensorflow is installed'){
      cat(paste0("Tensorflow and Python are properly installed.", "\n",
                "Now proceeding to run classify.", "\n"))
    }else{
      stop(cat(paste0("Tensorflow is not properly installed!", "\n", 
                      "Please see https://www.tensorflow.org/install for help.", "\n")))
    }
  }

  
  
  # load in data_info and store it in the model_dir
  # lbls <- utils::read.csv(data_info, header=FALSE)
  # lbls[,1] <- as.character(lbls[,1])
  # utils::write.table(lbls, "data_info.csv", sep=",",
  #                    row.names=FALSE, col.names=FALSE)
  #file.copy(from=data_info, to=paste0(wd, "/data_info.csv"), header=FALSE)
  
  if(os=="Windows"){
    # deal with windows file format issues
    # data_file <- read.table(data_info, header=FALSE, sep=",")
    # output.file <- file("data_info.csv", "wb")
    # write.table(data_file,
    #             file = output.file,
    #             append = TRUE,
    #             quote = FALSE,
    #             row.names = FALSE,
    #             col.names = FALSE,
    #             sep = ",")
    # close(output.file)
    # rm(output.file)
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
  
  # run code
  toc <- Sys.time()
  if(print_cmd){
    print(eval_py)
  }else{
    if(shiny){
      system(paste0("cd ", wd, "\n", # set directory using system because it can't be done in shiny
                    eval_py))
    } else {
      system(eval_py)
    }
  }


  tic <- Sys.time()
  runtime <- difftime(tic, toc, units="auto")
  
  # end function
  if(make_output==FALSE){
    txt <- paste0("evaluation of images took ", runtime, " ", units(runtime), ". ", "\n",
                  "The results are stored in ", model_dir, log_dir, save_predictions, ". ", "\n",
                  "To view the results in a viewer-friendly format, please use the function make_output", "\n")
    if(print_cmd == FALSE){
      cat(txt)
    }
  }

  # make output in this function too
  if(make_output){
    out <- utils::read.csv(paste0(wd, "/", save_predictions), header=FALSE)
    # set new column names
    colnames(out) <- c("rowNumber", "fileName", "answer", paste0("guess", 1:top_n), 
                       paste0("confidence", 1:top_n))
    utils::write.csv(out[,-1], paste0(output_location, "/", output_name))
    
    # put some info to user
    txt <- paste0("A csv with model predictions can be found here: ", output_location, "/", output_name)
    cat(txt)
  }
  
  # return to previous working directory
  setwd(wd1)
  
}

