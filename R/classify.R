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
#'  All images must be stored in this dictory, or a subdirectory from here.
#' @param data_info Name of a csv containing the file names of each image (including relative path from the \code{path_prefix}).
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
#'  the `species_model`, the number is `1000`. If using `empty_animal`, `num_classes=2`.
#'  If using `CFTEP`, `num_classes=10`
#' @param delimiter this will be a `,` for a csv.
#' @param log_dir If you are IDing species, this should be "species_model". If you are
#'  determining if images contain animals or if they are empty, this should be "empty_animal".
#'  If you trained a model with \code{train}, this
#'  will be the log_directory that you specified when using that function.
#'  If you are using the CFTEP model, specify "CFTEP" here. 
#' @param architecture the architecture of the deep neural network (DNN). Resnet-18 is the default.
#'  Options are c("alexnet", "densenet", "googlenet", "nin", "resnet", "vgg").
#'  If you are using the trained model that comes with MLWIC, use resnet 18 (the default).
#'  If you trained a model using a different architechture, you need to specify this same architechture and depth
#'  that you used for training.
#' @param num_cores The number of cores you want to use. You can find the number on your computer using
#'  parallel::detectCores()
#' @param depth the depth of the neural network. If you are using the built in model, do not adjust this parameter.
#'  If you are using a model that you trained, use the same architecture and depth as that model.
#' @param top_n the number of guesses you want the model to make (how many species do you want to
#'  see the confidence for?). This number must be less than or equal to `num_classes`.
#' @param model_dir Absolute path to the location where you stored the \code{MLWIC2_helper_files}
#'  that you downloaded from github. Note: you need to have unzipped this folder. 
#' @param batch_size The number of images for the model to evaluate in each batch. Larger numbers will run faster
#' @param make_output logical. Do you want the package to create a nice output file with column headers
#' @param output_name Desired name of the output file. It must end in `.csv`
#' @param test_tensorflow logical. Do you want to test your installation of tensorflow before running 
#'  \code{classify}? You want to do this the first time you run this function and any time you have made
#'  software changes on your computer, but on subsequent runs you can set this to FALSE. 
#'  
#' @details
#'  If you specify \code{make_output=TRUE}, the function will generate a csv with
#'  depicting your results. \code{answer} is the ground truth label that you supplied. 
#'  \code{guess1} is the model's top guess, and \code{confidence1} is the model's
#'  confidence in the top guess. 
#' 
#' @export
classify <- function(
  path_prefix = paste0(getwd(), "/images"), # absolute path to location of the images on your computer
  data_info = paste0(getwd(), "/image_labels.csv"), # csv with file names for each photo. See details
  model_dir = paste0(getwd(), "/MLWIC2_helper_files/"),
  log_dir = "species_model",
  save_predictions = "model_predictions.txt", # txt file where you want model output to go
  python_loc = "/anaconda3/bin/", # location of the python that Anacnoda uses on your machine
  os="Mac",
  num_classes = 1000, # number of classes in model
  num_cores = 1, 
  delimiter = ",", # this will be , for a csv.
  architecture = "resnet",
  depth = "18",
  top_n = 5,
  batch_size = 128,
  num_gpus = 2,
  make_output=TRUE,
  output_location=NULL,
  output_name = "MLWIC2_output.csv",
  test_tensorflow = FALSE,
  shiny=FALSE,
  print_cmd = FALSE
  
){
  
  wd1 <- getwd() # the starting working directory
  
  # set these parameters before changing directory
  path_prefix = path_prefix
  data_info = data_info
  model_dir = model_dir
  
  # added this so that the default is storing the output in the helper_files folder
  if(is.null(output_location)){
    output_location <- model_dir
  }
  
  # check if data_info file exists and if path_prefix exists
  if(!file.exists(data_info)){
    stop("Your `data_info` file (containing file names and classifications) does not exist.")
  } else{
    cat(paste0("Your `data_info` file exists: ", data_info, ".\n"))
  }
  if(!dir.exists(path_prefix)){
    stop("Your `path_prefix` (location of image files) does not exist.")
  } else {
    cat(paste0("Your `path_prefix exists: ", path_prefix, ".\n"))
  }
  if(os=="Windows"){
    cat("You are running on a Windows computer.\n")
  } else{
    cat("You are not using a Windows computer.\n")
  }

  # navigate to directory with trained model
  # if(endsWith(model_dir, "/")){
  #   setwd(paste0(model_dir, "log_dir"))
  # } else {
  #   setwd(paste0(model_dir, "/log_dir"))
  # }
  # wd <- getwd()
  
  # navigate to directory with trained model
  wd <- model_dir
  # if(shiny==FALSE){
     setwd(wd) # need to do this differently on not shiny because Windows uses cd command differently
  # }
  
  # add a / to the end of python directory if applicable
  python_loc <- ifelse(endsWith(python_loc, "/"), python_loc, paste0(python_loc, "/"))
  
  # test if tensorflow is installed
  if(test_tensorflow){
    if(print_cmd == FALSE ){
      sink("MLWIC2_test_tf.py")
      cat("import tensorflow as tf")
      cat("\n")
      cat("print('Tensorflow is installed')")
      cat("\n")
      cat("print(tf.__version__)")
      sink()
      test_tf <- paste0(python_loc, "python MLWIC2_test_tf.py")
      test_result <- system(test_tf, intern=TRUE, ignore.stderr = TRUE)
      if(exists("test_result") & test_result[1] == 'Tensorflow is installed'){
        cat(paste0("Tensorflow and Python are properly installed.", "\n",
                   "You are running tensorflow version ", test_result[2], "\n",
                   "Now proceeding to run classify.", "\n"))
      } else{
        stop(cat(paste0("Tensorflow is not properly installed.", "\n", 
                        "Please see https://www.tensorflow.org/install for help.", "\n")))
      }
      
    }
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
  if(os == "Windows"){
    eval_py <- paste0(python_loc,
                      "python run.py eval --num_threads ", num_cores, 
                      " --architecture ", architecture,
                      " --depth ", depth,
                      " --log_dir ", log_dir,
                      " --snapshot_prefix ", log_dir,
                      " --path_prefix ", path_prefix,
                      " --batch_size ", batch_size, 
                      " --val_info ", data_info,
                      " --delimiter ", delimiter,
                      #" --save_predictions ", paste0(wd, "\\", save_predictions),
                      " --save_predictions ", paste0(wd, "/", save_predictions),
                      " --top_n ", top_n,
                      " --num_gpus ", num_gpus,
                      " --num_classes ", num_classes, 
                      "\n")
  } else{
    eval_py <- paste0(python_loc,
                      "python run.py eval --num_threads ", num_cores, 
                      " --architecture ", architecture,
                      " --depth ", depth,
                      " --log_dir ", log_dir,
                      " --snapshot_prefix ", log_dir,
                      " --path_prefix ", path_prefix,
                      " --batch_size ", batch_size, 
                      " --val_info ", data_info,
                      " --delimiter ", delimiter,
                      " --save_predictions ", paste0(wd, "/", save_predictions),
                      " --top_n ", top_n,
                      " --num_gpus ", num_gpus,
                      " --num_classes ", num_classes, 
                      "\n")
  }

  
  # run code
  toc <- Sys.time()
  if(print_cmd){
    print(paste0("Navigate to your helper files in Anaconda Prompt by typing:",
                 "`cd ", model_dir, "`", 
                 " Then paste the command below"))
    print(gsub("\n", "", eval_py))
  }else{
      system(paste0(eval_py))
      #system(paste0("export PYTHONWARNINGS='ignore'\n",
      #              eval_py))

  }
  
  
  tic <- Sys.time()
  runtime <- difftime(tic, toc, units="auto")
  
  # end function
  if(make_output==FALSE){
    if(file.exists(paste0(wd, "/", save_predictions))){
      txt <- paste0("running the classify function took ", runtime, " ", units(runtime), ". ", "\n",
                    "The results are stored in ", model_dir, "/", save_predictions, ". ", "\n",
                    "To view the results in a viewer-friendly format, please use the function make_output", "\n"
                    )
      if(print_cmd == FALSE){
        #cat(txt) #*** comment this out when I update helper files
      }
    } else{
      cat("The classify function did not run properly.\n")
    }
  }
  
  # make output in this function too
  if(make_output){
    if(file.exists(paste0(wd, "/", save_predictions))){
      out <- utils::read.csv(paste0(wd, "/", save_predictions), header=FALSE)
      # set new column names
      colnames(out) <- c("rowNumber", "fileName", "answer", paste0("guess", 1:top_n), 
                         paste0("confidence", 1:top_n))
      utils::write.csv(out[,-1], paste0(output_location, "/", output_name))
      
      # put some info to user
      txt <- paste0("A csv with model predictions can be found here: ", output_location, "/", output_name)
      cat(txt)
    }else{
      if(!print_cmd){
        cat("The classify function did not run properly.\n")
      }
    }
    
    
  }
  
  # return to previous working directory
  setwd(wd1)
  #return(gsub("\n", "", eval_py))
}

# classify( path_prefix = '/Users/mikeytabak/MLWIC_examples/images/',
# data_info = '/Users/mikeytabak/MLWIC_examples/image_labels.csv',
# model_dir = '/Users/mikeytabak/MLWIC_examples/MLWIC2_helper_files',
# python_loc = '/anaconda3/bin',
# log_dir = 'species_model', num_classes = 59, save_predictions = 'model_predictions.txt', architecture = 'resnet', depth = 18, num_cores = 1, top_n = 5, batch_size = 128, output_name = 'MLWIC2_output.csv' ,
# print_cmd = TRUE)
