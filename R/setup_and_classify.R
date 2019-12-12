#' Automatically set up your computer to run \code{MLWIC2} and run \code{classify}
#' 
#' \code{setup_and_classify} is designed to be a simpler option for setting up and using \code{MLWIC}
#' to classify images for those uers who are less comfortable in computing. It requires fewer steps,
#' but also loses some of the flexibility associated with the functions it replaces (\code{setup}, 
#' \code{make_input}, \code{classify}, and \code{make_output}). This function will work with either
#' the species model or the empty/animal model. 
#' 
#' @param python_loc The location of python on your machine. If you are
#'  using a Macintosh, the default is the likely location.
#' @param conda_loc The location of conda. It is usually in the same folder as python
#' @param os The operating system on your computer. Options are "Mac", "Windows", "Ubuntu".
#' @param input_file The name of your input csv. It must contain a column called "filename"
#'  and unless you are using the built in model, a column called "class" (which would be your species or group of species).
#'  If you don't know what is in your images, it is easiest to not have in `input_file` and to specify
#'  `images_classified == FALSE`.
#' @param directory The directory of your `input_file`.
#' @param path_prefix Path to where your images are stored. You need to specify this if 
#'  you want MLWIC2 to `find_file_names`. 
#' @param image_file_suffixes The suffix for your image files. Only specify this if you are 
#'  using the `find_file_names` option. The default is .jpg files. This is case-sensitive.
#' @param images_classified logical. If TRUE, you have classifications to go along with these images
#'  (and you want to test how the model performs on these images).
#' @param already_downloaded_model logical. If TRUE, you have already downloaded the model and 
#'  will specify its location as `model_dir`. 
#' @param model_dir Absolute path to the location where you stored the trained folder
#'  that you downloaded from github. If you specified `already_downloaded_model=TRUE`, then this
#'  is the location where you stored the trained model folder.
#' @param model_type Do you want the model to ID species (`species`) or just determine if images are empty or
#'  containing animals (`empty_animal`)? 
#' @param output_name Desired name of the output file. It must end in `.csv`
#' @export

setup_and_classify <- function(
  python_loc = "/anaconda3/bin/",
  conda_loc = "auto",
  already_downloaded_model = FALSE,
  model_dir = getwd(),
  os = c("Mac", "Windows", "Ubuntu"),
  model_type = c("species", "empty_animal"),
  input_file = NULL,
  directory = getwd(),
  path_prefix = getwd(),
  image_file_suffixes = c(".jpg", ".JPG"),
  recursive = TRUE,
  images_classified = FALSE,
  output_name = "MLWIC2_output.csv",
  shiny=FALSE,
  print_cmd = FALSE
  
){
  stop("This function is not ready yet!")
  ## 1) install tensorflow: not sure of the best way to do this on Windows
  if(os == "Mac" | os == "Ubuntu"){
    MLWIC2::tensorflow(os=os)
  }
  # Windows ?
  
  ## 2) download the trained model and store it where the images are if this has not been done
  # already
  if(already_downloaded_model == FALSE){
    if(model_type=="species"){
      url <- "https://drive.google.com/open?id=1YGnHaVze7zBs_cRtgiFAgaBP_kz6xZPx.zip"
    }
    if(model_type == "empty_animal"){
      # add this URL when uploaded 
    }
    temp <- tempfile(fileext=".zip")
    utils::download.file(url, temp)
    out <- utils::unzip(temp, exdir=model_dir)
  }

  ## 3) Setup environment for MLWIC
  MLWIC2::setup(python_loc = python_loc,
                conda_loc = conda_loc,
                r_reticulate = FALSE)
  
  ## 4) make input file
  # first bring in an input file if one has been made by the user
  if(!is.null(input_file)){
    MLWIC2::make_input(input_file = input_file,
                       usingBuiltIn = TRUE, 
                       images_classified = images_classified,
                       directory=directory)
  } else{
    # if no input file, make one
    MLWIC2::make_input(usingBuiltIn = TRUE,
                       images_classified=FALSE,
                       path_prefix = path_prefix,
                       find_file_names = TRUE,
                       image_file_suffixes = image_file_suffixes,
                       recursive=recursive)
  }
  
  ## 5) Run classify
  
  
  

  
  
  
  
}

