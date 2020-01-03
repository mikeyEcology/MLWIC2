#' Remove spaces from all files within a directory
#'
#' \code{remove_spaces} removes paces from file names, which is required to 
#' run MLWIC2 functions on these images. In the future, it is good practice to 
#' avoid putting spaces in any folder or file name. 
#' 
#' @param path The path to the image files whose names need to be changed. The default
#'  is to use your current working directory.
#' @param pattern A vector containing the file name suffixes for which you want to
#'  change the name.
#' @export 
remove_spaces <- function(
  path = getwd(),
  pattern = c(".JPG", ".jpg")
){
  filist <- setdiff(list.files(path=path, pattern=paste0(pattern1, collapse="|")),
                    list.dirs(path=path, recursive = FALSE, full.names = FALSE))
  filist_ns <- gsub(" ", "_", filist, fixed=TRUE)
  file.rename(filist, filist_ns)
}
