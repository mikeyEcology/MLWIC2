#' A wrapper function to run Shiny Apps from \code{MLWIC2}.

#' @param app The name of the app you want to run. The options are currently 
#'  `classify` and `train`.
#' 
#' @export
runShiny <- function(app="classify") {
  # locate all the shiny app apps that exist
  validExamples <- list.files(system.file("shiny-apps", package = "MLWIC2"))
  
  validExamplesMsg <-
    paste0(
      "Valid shiny apps are: '",
      paste(validExamples, collapse = "', '"),
      "'")
  
  # if an invalid app is given, throw an error
  if (missing(app) || !nzchar(app) ||
      !app %in% validExamples) {
    stop(
      'Please run `runShiny()` with a valid app as an argument.\n',
      validExamplesMsg,
      call. = FALSE)
  }
  
  # find and launch the app
  appDir <- system.file("shiny-apps", app, package = "MLWIC2")
  shiny::runApp(appDir, display.mode = "normal")
}
