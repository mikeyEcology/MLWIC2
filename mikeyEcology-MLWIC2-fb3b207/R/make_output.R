#' Present output from a dataset classified by \code{MLWIC}
#'
#' \code{make_output} will make a clean csv presenting the results from your run
#' of \code{classify}. If you are planning to avoid typing absolute paths, you need to first
#' set your working directory to the location where you stored your images folder and data_info csv. 
#' If you set this function to run and assign it to a variable, you can specify \code{return_df=TRUE}
#' and produce a variable in your R session that is the model output. 
#'
#' @param output_location Absolute path where you want the output csv stored. This path
#'  must exist on your computer.
#' @param output_name Desired name of the output file. It must end in `.csv`
#' @param saved_predictions This is the file name where you stored predictions when you ran
#'  \code{classify}. If you used the default in that function, you can use the default here.
#' @param model_dir Absolute path to the location where you stored the L1 folder
#'  that you downloaded from github.
#' @param return_df If TRUE, this will return the model output. This allows you to create a variable that 
#'  is the model output. 
#' @param top_n The number of guesses that you wanted classify to save. This needs to mach what you specified 
#'  for top_n in \code{classify}
#' @export
make_output <- function(
  output_location, #=getwd(),
  model_dir, #=getwd(),
  output_name = "output.csv",
  saved_predictions = "model_predictions.txt",
  return_df = FALSE,
  top_n = "5",
  shiny=FALSE
){
  
  wd1 <- getwd() # the starting working directory
  # set these parameters before changing directory
  output_location = as.character(output_location)
  model_dir = model_dir
  
  #- read in text file of model output
  # navigate to directory with trained model
  if(shiny){ # shiny can't handle using endsWith function
    wd2 <- (paste0(model_dir, "/trained_model"))
  }else{
    if(endsWith(model_dir, "/")){
      wd2 <- (paste0(model_dir, "trained_model"))
    } else { 
      wd2 <- (paste0(model_dir, "/trained_model"))
    }
  }

  # if(shiny){
  #   utils::read.csv(paste0(wd2, "/", saved_predictions), header=FALSE)
  # }else{
  #   setwd(wd2)
  #   out <- utils::read.csv(saved_predictions, header=FALSE)
  # }
  
  out <- utils::read.csv(paste0(wd2, "/", saved_predictions), header=FALSE)
  
  # set new column names
  colnames(out) <- c("rowNumber", "fileName", "answer", paste0("guess", 1:top_n), 
                     paste0("confidence", 1:top_n))

  
  # output
  if(shiny){
    output_full <- paste0(output_location, "/", output_name)
  } else {
    if(endsWith(output_location, "/")){
      output_full <- paste0(output_location, output_name)
    } else {
      output_full <- paste0(output_location, "/", output_name)
    }
  }
 
  utils::write.csv(out[,-1], output_full)
  
  print(paste0("Output can be found here: ", output_full))
  
  # save the output
  if(return_df){
    return(out)
  }
  
  # return to previous working directory
  if(shiny == FALSE){
    setwd(wd1)
  }
}
