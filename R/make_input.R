#' Create an input file to run \code{classify} or \code{train} in \code{MLWIC}
#'
#' \code{make_input} will make a csv with the specifications necessary to either classify 
#' images or to train a new model. If you are using the `find_file_names` option, you
#' only need to specify the `path_prefix` where all of your images are located and this
#' function will generate a file to use with `classify`. Otherwise, you must provide an 
#' `input_file` which contains columns called "filename". If you are using images that have 
#' been classified and you want to evaluate how the model works on these images, set 
#' `images_classified=TRUE` and your `input_file`` must also contain a column called either "class", 
#' which contains each image's text classification or "class_ID" which contains a number matching
#' the \code{speciesID} table.
#' 
#' @param input_file The absolute path to your input csv. It must contain a column called "filename"
#'  and unless you are using the built in model, a column called "class" (which would be your species or group of species).
#' @param find_file_names logical. If TRUE, this function will find all image files within a 
#'  specified directory. You must specify the directory (`path_prefix`) for this to work.
#'  If you already have a spreadsheet (eg. a `.csv`) with the names of files and their classifications,
#'  this is not the option for you. 
#' @param path_prefix Path to where your images are stored. You need to specify this if 
#'  you want MLWIC2 to `find_file_names`. 
#' @param image_file_suffixes The suffix for your image files. Only specify this if you are 
#'  using the `find_file_names` option. The default is .jpg files. This is case-sensitive.
#' @param recursive logical. Only necessary if you are using the `find_file_names` option. 
#'  If TRUE, the function will find all relevant image files in all subdirectories from the 
#'  path you specify. If FALSE, it will only find images in the folder that you provide as your 
#'  `path_prefix`.
#' @param usingBuiltIn logical. If TRUE, you are setting up a data file to classify images using
#'  the built in model. 
#' @param model_type If usingBuiltIn=TRUE, you can specify `species_model` or `empty_animal` so that 
#'  your class_ID's will match those of the model
#' @param images_classified logical. If TRUE, you have classifications to go along with these images
#'  (and you want to test how the model performs on these images).
#' @param find_class_IDs logical. If TRUE, and you have images_classified, MLWIC2 will try to match up
#'  your text classifications with the values from the trained model. If FALSE and you have images classified,
#'  you need to have a column in your input file called `class_ID`. 
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
  find_file_names = FALSE,
  path_prefix = getwd(),
  image_file_suffixes = c(".jpg", ".JPG"),
  recursive = TRUE,
  usingBuiltIn = TRUE, 
  model_type = "species_model",
  images_classified = FALSE,
  find_class_IDs = FALSE,
  trainTest = FALSE, 
  file_prefix = "pre_",
  propTrain = 0.9
){
  
  # make sure there is not overlapping logic
  if(usingBuiltIn == TRUE & trainTest == TRUE){
    stop("You have specified trainTest == TRUE and usingBuiltIn == TRUE. \n
         This does not make sense because you do not want to make separate train and \n
         test files if you are using the built in model. trainTest is only used if \n
         you are building a model. ")
  }
  if(trainTest==TRUE & images_classified == FALSE){
    stop("You have specified trainTest == TRUE and images_classified == FALSE. \n
         This does not make sense because you cannot train a model if you do not \n
         have classified images.")
  }
  if(find_file_names == TRUE & images_classified == TRUE){
    stop("You have specified find_file_names==TRUE and images_classified==TRUE. \n
         When MLWIC2 executes the find_file_names option it cannot accept image \n
         classifications associated with each image. If you want to supply \n
         image classifications, you need to supply an input_file. ")
  }
  if(find_file_names == TRUE & is.null(path_prefix)){
    stop("You have specified find_file_names==TRUE and but you have not specified the \n
         directory where your image files are located on your computer.")
  }
  
  # make input file using only the path
  if(find_file_names){
    # make a pattern argument for list_files because it cannot take a vector
    pattern <- paste0(image_file_suffixes, collapse="|")
    
    # find file names in directory
    file_names <- list.files(path = path_prefix,  
                             pattern=pattern,
                             full.names=FALSE, recursive=recursive)
    df <- data.frame(file_names, rep(0, length(file_names)))
    output.file <- file(paste0(path_prefix, "/","image_labels.csv"), "wb")
    write.table(df,
                row.names = FALSE,
                col.names = FALSE,
                file = output.file,
                quote = FALSE,
                append = TRUE,
                sep = ",")
    close(output.file)
    rm(output.file) 
   cat(paste0("Your file is located at '", path_prefix, "/", "image_labels.csv'. This is the same location where your images are stored."))
  } else {
    # load in file
    inFile <- utils::read.csv(input_file)
    
    if(usingBuiltIn){
      if(images_classified){
        if(find_class_IDs){
          cnames <- colnames(inFile)
          cnames_shouldBe <- c("class_ID", "filename")
          cnames_bool <- cnames_shouldBe %in% cnames
          if(any(!cnames_bool)){
            stop("You have specified that you want MLWIC2 to find_class_IDs. In order to do this,\n
                 your inFile must contain a column called `class_ID` and a column called `filename`")
          }
          
          # setup a lower case
          speciesID <- speciesID
          contains <- (data.frame(lapply(speciesID[, 2:19], as.character), stringsAsFactors = FALSE))
          contains <- sapply(contains, FUN=tolower)
          
          # test finding a classID of a name
          # nm <- tolower("Cow")
          # rowOfClass <- which(contains == nm, arr.ind=TRUE)[1]
          # #grep(nm, contains, ignore.case=TRUE, value=FALSE)
          # class_ID <- speciesID[rowOfClass,1]
          # inFile <- data.frame(class = c("Cattle", "chickadee", "nada", "Eagle", "Eagle", "skunk"), num = 1:6)
          
          # function to get the classID of a given class
          findClassID <- function(x){
            rowOfClass <- which(contains == tolower(x), arr.ind=TRUE)[1]
            class_ID <- speciesID[rowOfClass,1]
            return(class_ID)
          }
          inFile$class_ID <- sapply(inFile$class_ID, findClassID)
          
          if(model_type == "empty_animal"){
            # if we're using the empty animal model, change to either 0 or one. 
            inFile$class_ID_EA <- ifelse(inFile$class_ID == 27, 0, 1)
            inFile$class_ID <- inFile$class_ID_EA
          } # if species_model, leave as is. 
          
          # make some output to show how classes were changed
          class_IDs_new <- inFile[match(unique(inFile$class), inFile$class), "class_ID"]
          old_new <- data.frame(input_class = unique(inFile$class), 
                                class_ID =class_IDs_new)
          nas <- old_new[(is.na(old_new$class_ID)),]
          nas_df <- data.frame(nas, group_name=rep("none", nrow(nas)))
          old_new2 <- merge(old_new, speciesID, by="class_ID")
          old_new3 <- data.frame(input_class = old_new2$input_class, 
                                 class_ID = old_new2$class_ID, 
                                 group_name = old_new2$group_name)
          old_new4 <- rbind(old_new3, nas_df)
          
          # return a talbe showing how their labels were changed
          # cat("This function will return a table of how your class names were changed
          #     to make class_ID's to match the function. If you are not happy with these, 
          #     it is best for you to find class_IDs for your species using the table here:
          #     https://github.com/mikeyEcology/MLWIC2/blob/master/speciesID.csv and specifying
          #     find_class_IDs=FALSE the next time you run `make_input`")
          #return(old_new4)
          
          # remove rows from input file where there is no matching classID
          inFile2 <- inFile[!is.na(inFile$class_ID),]
          
          # write output
          df <- data.frame(inFile2$filename, inFile2$class_ID)
          output.file <- file(paste0(path_prefix, "/", file_prefix, "image_labels.csv"), "wb")
          write.table(df,
                      row.names = FALSE,
                      col.names = FALSE,
                      file = output.file,
                      quote = FALSE,
                      append = TRUE,
                      sep = ",")
          close(output.file)
          rm(output.file) 
          print(paste0("Your file is located at ", path_prefix, "/", file_prefix, "image_labels.csv."))
          
           
        } else { # not finding file names; user is supplying class_ID. 
          cnames <- colnames(inFile)
          cnames_shouldBe <- c("class_ID", "filename")
          cnames_bool <- cnames_shouldBe %in% cnames
          if(any(!cnames_bool)){
            stop("You have specified that you want MLWIC2 to make an input file using your class_IDs and \n
                 filenames. Your input file must contain a column called `class_ID` and a column called `filename`")
          }
        # here we are just essentially reading and writing the file
        
        # write output
        df <- data.frame(inFile$filename, inFile$class_ID)
        output.file <- file(paste0(path_prefix, "/", file_prefix, "image_labels.csv"), "wb")
        write.table(df,
                    row.names = FALSE,
                    col.names = FALSE,
                    file = output.file,
                    quote = FALSE,
                    append = TRUE,
                    sep = ",")
        close(output.file)
        rm(output.file)
        print(paste0("Your file is located at ", path_prefix, "/", file_prefix, "image_labels.csv."))
        
        } # end not finding file names; user is supplying class_ID. 
        
        
      } else { # images not classified, but using builtin
        cnames <- colnames(inFile)
        cnames_bool <- "filename" %in% cnames
        if(any(!cnames_bool)){
          stop("Your input_file does not contain a column called 'filename'")
        } 
        df <- data.frame(inFile$filename, rep(0, nrow(inFile)))
 
      
      
      # write output
      output.file <- file(paste0(path_prefix, "/", file_prefix, "image_labels.csv"), "wb")
      write.table(df,
                  row.names = FALSE,
                  col.names = FALSE,
                  file = output.file,
                  quote = FALSE,
                  append = TRUE,
                  sep = ",")
      close(output.file)
      rm(output.file) 
      print(paste0("Your file is located at ", path_prefix, "/", file_prefix, "image_labels.csv."))
      
      } # end images not classified, but using builtin
      
    } else { # (not using builtin)
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
      
      if(images_classified){ # not using builtin
        # create a lookup table
        group_name <- unique(inFile$class) 
        class_ID <- seq_along(group_name)
        tblLu <- data.frame(class_ID, group_name)
        
        # make a df that contains the ID for each file
        df1 <- merge(inFile, tblLu, by.x="class", by.y="group_name")
        df2 <- data.frame(df1$filename, df1$class_ID)
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
      
    } # end if not using builtin
    
     if(images_classified & !(usingBuiltIn)){
       # return the lookup table
       return(tblLU)
     }
    
  } # end else for not using find_file_names
}

 # make_input(input_file="/Users/mikeytabak/MLWIC_examples/image_labels_headers.csv",
 #            images_classified = TRUE, find_class_IDs=FALSE)
