#' Create an input file to run \code{classify} or \code{train} in \code{MLWIC}
#'
#' \code{make_inpu} will make a csv with the specifications necessary to either classify 
#' images or to train a new model. Your `input_file` must contain a column called "filename"
#' and a column called "species".
#' 
#' @param input_file The name of your input csv. It must contain a column called "filename"
#'  and unless you are using the built in model, a column called "class" (which would be your species or group of species).
#' @param usingBuiltIn logical. If TRUE, you are setting up a data file to classify images using
#'  the built in model. 
#' @param images_classified logical. If TRUE, you have classifications to go along with these images
#'  (and you want to test how the model performs on these images).
#' @param directory Directory of your input csv. The default option is your working directory.
#'  The file created by this function will be stored in this same directory. 
#' @param trainTest logical. Do you want to create separate csvs for training and testing
#' @param file_prefix What you want to appear as the filename before the suffix. If you are
#'  only creating a file to test the model, you could specify "test_" and your output file name
#'  would be "test_image_labels.csv". If you specify `trainTest = TRUE`, your suffixes will automatically be
#'  "_train.csv" and "_test.csv"
#' @param propTrain proportion of images you want for training. `1-propTrain` is the proportion
#'  that will be used for testing the model. 
#' @export

make_input <- function(
  input_file = NULL,
  usingBuiltIn = TRUE, 
  images_classified = FALSE,
  trainTest = FALSE, 
  file_prefix = "",
  propTrain = 0.9, 
  directory = getwd()
){
  
  # 
  if(usingBuiltIn == TRUE & trainTest == TRUE){
    stop("You have specified trainTest == TRUE and usingBuiltIn == TRUE. \n
         This does not make sense because you do not want to make separate train and \n
         test files if you are using the built in model")
  }
  if(trainTest==TRUE & images_classified == FALSE){
    stop("You have specified trainTest == TRUE and images_classified == FALSE. \n
         This does not make sense because you cannot train a model if you do not \n
         have classified")
  }
  
  # get in file
  if(endsWith(directory, "/")){
    inFile <- (paste0(directory, input_file))
    wd <- directory
  } else {
    inFile <- (paste0(directory, "/", input_file))
    wd <- paste0(directory, "/")
  }
  
  if(usingBuiltIn){
    cnames <- colnames(inFile)
    cnames_bool <- "filename" %in% cnames
    if(!cnames_bool){
      stop("Your inFile does not contain a column called 'filename'")
    } 
    df <- data.frame(inFile$filename, rep(0, nrow(inFile)))
    
    # write output
    output.file <- file(paste0(file_prefix, "image_labels.csv"), "wb")
    write.table(df,
                row.names = FALSE,
                col.names = FALSE,
                file = output.file,
                quote = FALSE,
                append = TRUE,
                sep = ",")
    close(output.file)
    rm(output.file) 
    print(paste0("Your file is located at ", directory, file_prefix, "image_labels.csv."))
    
  } else{
    cnames <- colnames(inFile)
    if(images_classified){
      cnames_shouldBe <- c("class", "filename")
    } else{
      cnames_shouldBe <- c("filename")
    }
    
    cnames_bool <- cnames_shouldBe %in% cnames
    if(any(cnames_bool==FALSE)){
      stop("The column names in your input_file must include 'class' and 'filename'. \n
           The 'class' column contains the names of the species in each image. ")
    }
    
    if(images_classified){
      # create a lookup table
      group_name <- unique(inFile$class) # species <- c("aa", "bb", "cc")
      speciesID <- seq_along(group_name)
      tblLu <- data.frame(speciesID, group_name)
      
      # make a df that contains the ID for each file
      df1 <- merge(inFile, tblLu, by.x="class", by.y="group_name")
      df2 <- data.frame(df1$filename, df1$speciesID)
    } else{
      df2 <- data.frame(inFile$filename, rep(0, nrow(inFile)))
    }

    # write out data frame
    if(trainTest==FALSE){ 
      output.file <- file(paste0(file_prefix, "image_labels.csv"), "wb")
      write.table(df2,
                  row.names = FALSE,
                  col.names = FALSE,
                  file = output.file,
                  quote = FALSE,
                  append = TRUE,
                  sep = ",")
      close(output.file)
      rm(output.file) 
      print(paste0("Your file is located at ", wd, file_prefix, "image_labels.csv."))
    } else {
      # set up training and testng datasets
      ntrain <- floor(nrow(df2)*proptrain)
      ntest <- nrow(df2) - ntrain
      train_rows <- sample(nrow(df2), ntrain, replace=FALSE)
      df.train <- df2[train_rows,]
      df.test <- df2[-train_rows,]
      # write it out
      output.file <- file(paste0(file_prefix, "_train.csv"), "wb")
      write.table(df.train,
                  row.names = FALSE,
                  col.names = FALSE,
                  file = output.file,
                  quote = FALSE,
                  append = TRUE,
                  sep = ",")
      close(output.file)
      rm(output.file) 
      
      output.file <- file(paste0(file_prefix, "_test.csv"), "wb")
      write.table(df.train,
                  row.names = FALSE,
                  col.names = FALSE,
                  file = output.file,
                  quote = FALSE,
                  append = TRUE,
                  sep = ",")
      close(output.file)
      rm(output.file) 
      
      # print information
      print(paste0("Your files are located in ", wd, "\n
                   With the file names: ", file_prefix, "_test.csv and \n", 
                   file_prefix, "train.csv."))
    }

  }
  
  if(images_classified){
    # return the lookup table
    return(tblLU)
  }

  
}