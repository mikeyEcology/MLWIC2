#' Write model predictions from \code{MLWIC2} to image files
#'
#' Uses `exiftool` to add metadata to your image files based on output from running
#' \code{classify} on your images. You must have ExifTool installed on your machine
#' for this function to work (https://exiftool.org/install.html). This function is designed
#' for those users who want to be able to view their classified images in software like ...
#' At this point you need to have a dataframe in your session called speciesID which is
#' the csv that is available here https://github.com/mikeyEcology/MLWIC2/blob/master/speciesID.csv
#' 
#' @param output_location The path to the output file that you created with \code{classify} or \code{make_output}
#' @param output_name The name of the output file that you created with \code{classify} or \code{make_output}
#' @param model_type Did you run the model to ID species (`species`) or just determine if images are empty or
#'  containing animals (`empty_animal`)? 
#' @param show_sys_output logical. If TRUE, shows the output from the system command
#' @export
write_metadata <- function(
  output_location = getwd(),
  output_name = "MLWIC2_output.csv",
  model_type = c("species", "empty_animal"), 
  show_sys_output = FALSE
){
  
  # create the config file that adds categories for output to the metadata
 txt <-"%Image::ExifTool::UserDefined = (
    'Image::ExifTool::Exif::Main' => {
      0xd000 => {
        Name => 'MLWIC2_speciesmodel_classID',
        Writable => 'int16u',
      },
      0xd001 => {
        Name => 'MLWIC2_speciesmodel_species',
        Writable => 'string',
      },
      0xd002 => {
        Name => 'MLWIC2_speciesmodel_confidence',
        Writable => 'rational64s',
      },
      0xd003 => {
        Name => 'MLWIC2_emptyanimalmodel_emptyID',
        Writable => 'int16u',
      },
      0xd004 => {
        Name => 'MLWIC2_emptyanimalmodel_answer',
        Writable => 'string',
      },
      0xd005 => {
        Name => 'MLWIC2_emptyanimalmodel_confidence',
        Writable => 'rational64s',
      },
      
    }
  )"
 fileConn<-file("MLWIC2_exif.config")
 writeLines(txt, fileConn)
 close(fileConn)
 
 # read in output file created by MLWIC2
 output <- read.csv(paste0(output_location, "/", output_name))
 filenames <- gsub("b'", "", output$fileName) # remove quotes and b' from filenames
 filenames2 <- gsub("'", "", filenames)
 output$fileName <- filenames2
 
 # merge speciesID csv with output
 out_m <- merge(output, speciesID, by.x="guess1", by.y="class_ID")
 
 # write call to exiftool
 n_files <- nrow(output)
 for(i in 1:n_files){
   if(model_type == "species"){
     exif_call <- paste0("exiftool -config ", getwd(), "/MLWIC2_exif.config -MLWIC2_speciesmodel_classID=", 
                         out_m$guess1[i], " -MLWIC2_speciesmodel_species=", shQuote(out_m$group_name[i]), 
                         " -MLWIC2_speciesmodel_confidence=", out_m$confidence1[i],
                         out_m$fileName[i])
   } 
   if(model_type == "empty_animal"){
     exif_call <- paste0("exiftool -config ", getwd(), "/MLWIC2_exif.config -MLWIC2_emptyanimalmodel_emptyID ", 
                         out_m$guess1[i], " -MLWIC2_emptyanimalmodel_answer ", out_m$group_name[i], 
                         " -MLWIC2_emptyanimalmodel_confidence ", out_m$confidence1[i],
                         " ", out_m$fileName[i])
   }
   system(exif_call, ignore.stdout = !show_sys_output, ignore.stderr = !show_sys_output)
   if(i %% 100 == 0){
     cat(paste0("completed writing metadata for ", i, " of ", n_files, " images.\n"))
   }
 }
 
}