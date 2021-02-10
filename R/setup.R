#' Setup your computer to run \code{MLWIC2}
#'
#'
#' \code{setup} installs necessary Python packages on your computer. You will
#' need to run this before running \code{classify} and \code{train}. If this is your first time using
#' this function, you should see additional documentation at https://github.com/mikeyEcology/MLWIC2.
#' If you follow the link to install Anacoda and you are using a Mac, python should be in the default location.
#'
#' @param python_loc The location of python on your machine. If you are
#'  using a Macintosh, the default is the likely location. 
#' @param conda_loc The location of conda. It is usually in the same folder as python
#' @param r_reticulate Logical. Do you have an environment called "r-reticulate" for which you have
#'  installed Python packages previously and want to retain these packages. Default is FALSE.
#' @param gpu Logical. Do you want to use a GPU for classifying and training. (You must have
#'  a GPU on your machine for this to work).
#' @param python_version set to the version of python you want to use. Use <= 3.7
#' @param envname The name of the conda environment you'd like to set up. 
#'  If you don't manage multiple environments, leave this as default
#'
#' @export
setup <- function(
  python_loc = "/anaconda3/bin/",
  gpu = FALSE,
  conda_loc = "auto", #"/anaconda2/bin/conda",
  r_reticulate = FALSE,
  python_version = "3.7",
  envname="r-reticulate"
){
  # load reticulate
  reticulate::use_python(python_loc)
  
  # packages needed for MLWIC
  if(gpu){
    packs <- c(
      "numpy==1.16.4", "cycler", "matplotlib", "tornado", 
      "six", "scipy", 
      "tensorflow-gpu==1.14.0"
    )
  }else{
    packs <- c(
      "numpy==1.16.4", "cycler", "matplotlib", "tornado", 
      "six", "scipy", 
      "tensorflow==1.14.0"
    )
  }
  
  #- create a conda environment if it doesn't already exist
  if(!r_reticulate){
    # first remove conda environment
    reticulate::conda_remove("r-reticulate")
    # then create it
    reticulate::conda_create("r-reticulate", conda=conda_loc)
  }
  
  # install python packages
  cat("This function will now install some python packages that are required to run MLWIC2. 
      It will take some time. You will see a lot of output regarding the installation and 
      updating of python packages.\n")
  reticulate::py_install(packs, conda=conda_loc, python_version = python_version
                         , envname = envname)
  
}
