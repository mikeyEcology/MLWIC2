#' Write model predictions from \code{MLWIC2} to image files
#'
#' Uses `exiftool` to add metadata to your image files based on output from running
#' \code{classify} on your images. You must have ExifTool installed on your machine
#' for this function to work (https://exiftool.org/install.html). This function is designed
#' for those users who want to be able to view their classified images along with the classifications
#' from \code{MLWIC} in software like digiKam, MediaPro, and Lighthouse. 
#' 
#' @param output_file The path to- and file name of the csv file that you created with \code{classify} or \code{make_output}.
#'  This is likely in the MLWIC2_helpers_folder unless you deviated from the defaults. 
#' @param model_type Did you run the (`species_model`) or the (`empty_animal`) model? 
#' @param show_sys_output logical. If TRUE, shows the output from the system command
#' @export
write_metadata <- function(
  #path_prefix = getwd(),
  output_file = paste0(getwd(),"/","MLWIC2_output.csv"),
  model_type = c("species_model", "empty_animal"), 
  exiftool_loc = NULL, 
  show_sys_output = FALSE
){
  
  # determine if Windows
  if(Sys.info()["sysname"] == "Windows"){
    Windows <- TRUE
  } else {
    Windows <- FALSE
  }
  
  #setwd(path_prefix)
  
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
 output <- read.csv(output_file)
 filenames <- gsub("b'", "", output$fileName) # remove quotes and b' from filenames
 filenames2 <- gsub("'", "", filenames)
 output$fileName <- filenames2
 
 # make a lookup table for empty_animal model
 EA_lookup <- data.frame(class_ID=c(0,1),
                         group_name=c("empty", "animal"))
 
 # determine lookup table based on model
 if(model_type=="species_model"){
   ID_tbl <- speciesID
 } else {
   ID_tbl <- EA_lookup
 }
 # merge lookup table with output
 out_m <- merge(output, ID_tbl, by.x="guess1", by.y="class_ID")
 
 # add a prefix to location of exiftool when needed (Windows computers)
 if(!is.null(exiftool_loc) & !identical(exiftool_loc, character(0))){
   prefix <- ifelse(endsWith(exiftool_loc, "/"), python_loc, paste0(exiftool_loc, "/")) #paste0(exiftool_loc, "/") 
 } else{
   prefix <- "" # no prefix if exiftool_loc isn't specified
 }
 
 # add a suffix for Windows
 if(Windows){
   suffix <- ".exe"
 } else{
   suffix <- ""
 }
 
 # write call to exiftool
 n_files <- nrow(output)
 for(i in 1:n_files){
 #for(i in 1:10){ 
   if(model_type == "species_model"){
     exif_call <- paste0(prefix, "exiftool", suffix, " -config ", getwd(), "/MLWIC2_exif.config -MLWIC2_speciesmodel_classID=", 
                         out_m$guess1[i], " -MLWIC2_speciesmodel_species=", shQuote(out_m$group_name[i]), 
                         " -MLWIC2_speciesmodel_confidence=", out_m$confidence1[i],
                         out_m$fileName[i])
   } 
   if(model_type == "empty_animal"){
     exif_call <- paste0(prefix, "exiftool", suffix, " -config ", getwd(), "/MLWIC2_exif.config -MLWIC2_emptyanimalmodel_emptyID ", 
                         out_m$guess1[i], " -MLWIC2_emptyanimalmodel_answer ", out_m$group_name[i], 
                         " -MLWIC2_emptyanimalmodel_confidence ", out_m$confidence1[i],
                         " ", out_m$fileName[i])
   }
   system(exif_call, ignore.stdout = !show_sys_output, ignore.stderr = !show_sys_output)
   if(i==1){
     cat(paste0("completed writing metadata for ", i, " of ", n_files, " images.\nThis function will provide status updates after every 100 image files updated.\n"))
   }
   if(i %% 100 == 0){
     cat(paste0("completed writing metadata for ", i, " of ", n_files, " images.\n"))
   }
 }
 
}
#write_metadata(output_file="/Users/mikeytabak/MLWIC_examples/MLWIC2_helper_files/MLWIC2_output.csv", exiftool_loc="/usr/local/bin", model_type="species_model", show_sys_output = TRUE)

