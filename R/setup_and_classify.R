

#' @param python_loc The location of python on your machine. If you are
#'  using a Macintosh, the default is the likely location.
#' @param conda_loc The location of conda. It is usually in the same folder as python
#' @param os The operating system on your computer. Options are "Mac", "Windows", "Ubuntu".


setup_and_classify <- function(
  python_loc = /anaconda3/bin/,
  conda_loc = "auto",
  os = c("Mac", "Windows", "Ubuntu"),
  
)