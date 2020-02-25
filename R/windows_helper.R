#' A helper function to make shiny work on Windoes computers
#'
#'
#' \code{windows_helper} is an internal function
#' 
#' @param input input from shiny
#' @param FUN # function to run
#' @export
windows_helper <- function(
  FUN, input
){
do.call(FUN, input)
  #return(input)
}

FUN <- eval(noquote("plot(density(rnorm(100,0,1)))"))
do.call(rnorm, args=list(mean=0, n=10, 1))
windows_helper(classify, windows_input)
