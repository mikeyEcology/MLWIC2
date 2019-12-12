

#' @param python_loc The location of python on your machine. If you are
#'  using a Macintosh, the default is the likely location.
#' @param conda_loc The location of conda. It is usually in the same folder as python
#' @param os The operating system on your computer. Options are "Mac", "Windows", "Ubuntu".
#' @param input_file The name of your input csv. It must contain a column called "filename"
#'  and unless you are using the built in model, a column called "class" (which would be your species or group of species).
#' @param path_prefix Path to where your images are stored. You need to specify this if 
#'  you want MLWIC2 to `find_file_names`. 
#' @param image_file_suffixes The suffix for your image files. Only specify this if you are 
#'  using the `find_file_names` option. The default is .jpg files. This is case-sensitive.
#' @param images_classified logical. If TRUE, you have classifications to go along with these images
#'  (and you want to test how the model performs on these images).
#' @param model_dir Absolute path to the location where you stored the trained folder
#'  that you downloaded from github.
#' @param output_name Desired name of the output file. It must end in `.csv`
#' @export

setup_and_classify <- function(
  python_loc = "/anaconda3/bin/",
  conda_loc = "auto",
  model_dir = getwd(),
  os = c("Mac", "Windows", "Ubuntu"),
  input_file = NULL,
  path_prefix = NULL,
  image_file_suffixes = c(".jpg", ".JPG"),
  images_classified = FALSE,
  output_name = "MLWIC2_output.csv",
  shiny=FALSE,
  print_cmd = FALSE
  
){
  
}