# MLWIC2: Machine Learning for Wildlife Image Classification

MLWIC2 is similar to the [MLWIC](https://github.com/mikeyEcology/MLWIC) package, it contains two models: the `species_model` identifies [58 species](https://github.com/mikeyEcology/MLWIC2/blob/master/speciesID.csv) and empty images, and the `empty_animal` model distinguishes between images with animals and those that are empty. MLWIC2 also contains Shiny apps for running the functions. These can be accessed using `runShiny`. In the steps below, you can see <i>Shiny options</i> for some steps. This indicates that you can run these steps with Shiny apps by running the function provied. Note that when you are using Shiny apps to select directories and files, you can only navigate using the top part half of the screen. 

You need to have [Anaconda Navigator](https://docs.anaconda.com/anaconda/navigator/) installed, along with Python 3.7 (Python 3.6 or 3.5 will also work just as well). 
If you are using a Windows computer, you will likely need to install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) if you don't already have it installed. 

## <b>Step 1: Install the `MLWIC2` package in R</b>
```
# install devtools if you don't have it
if (!require('devtools')) install.packages('devtools')
# check error messages and ensure that devtools installed properly. 

# install MLWIC2 from github
devtools::install_github("mikeyEcology/MLWIC2") 
# This line might prompt you to update some packages. It would be wise to make these updates. 

# load this package
library(MLWIC2)
```

You only need to run steps 2-4 the first time you use this package on a computer. If you have already run [MLWIC](https://github.com/mikeyEcology/MLWIC) on your computer, you can skip steps 2 and 4

## <b>Step 2: Install TensorFlow (version 1.14) on your computer.</b>
Really any version of tensorflow > 1.8 and < 2.0 will do. \
The function `tensorflow` will do this on Macintosh and Linux machines, but the installation of this software is inconsistent. If you have trouble using our function or you are using a Windows computer, you can do this independently by following the directions [here](https://www.tensorflow.org/install/), except when the instructions say to run `pip install tensorflow`, you should instead run:  `pip install tensorflow==1.14`.

## <b>Step 3: Download the [MLWIC2_helper_files folder from this link](https://drive.google.com/file/d/1M1pl9edaaIZqcQkCndLcvEcbOOkSrTQB/view?usp=sharing).</b> 
- This link was updated 25 March 2020. The previous link will run the models the same, but the output will be cleaner if you download this newer zipped folder. 
- Unzip the folder and then store this folder in a location that makes sense on your computer (e.g., Desktop). Note the location, as you will specify this as `model_dir` when you run the functions `classify`, `make_output`, and `train`. (optional) If you want to check md5sums for this file, the value should be `4f3d57ea4d17055cac5df3591f87bbb3`. 

## <b>Step 4: Setup your environment for using `MLWIC2` using the function `setup`</b>
###### <i> Shiny option: `MLWIC2::runShiny('setup')` </i>
- `python_loc` is the location of Python on your computer. On Macs, it is often in the default-you can determine the location by opening a terminal window and typing `which python`. In Windows you can open your command prompt and type `where python`. 
- If you already have a conda environment called "r-reticulate" with Python packages installed, you can specify `r_reticulate = TRUE`; if you don't know what this means, leave this argument as the default by not specifying it. \
- This function installs several necessary Python packages. Running this function will take a few minutes. You may see some errors when you run `setup` - you can ignore these; if there are problems with the installation, whey will become apparent when you run `classify`. 

###### Before running models on your own data, I recommend you try running using the [example  provided](https://github.com/mikeyEcology/MLWIC_examples/tree/master). 

## <b> Step 5: Create a properly formatted input file using `make_input`</b>
###### <i> Shiny option: `MLWIC2::runShiny('make_input')` </i>
- Option 1: If you have labels for your images and you want to test the model on your images (set `images_classified=TRUE`), you need to have an `input_file` csv that has at last two columns and one of these must be "filename" and the other must be "class_ID".
   - `class_ID` is a column containing a number for the label for each species. If you're using the "species_model", you can find the class_ID associated with each species in  [this table](https://github.com/mikeyEcology/MLWIC2/blob/master/speciesID.csv) and put them in this column. 
- Option 2: This is the same as option 1, excpet instead of having a column `class_ID` containing the number associated with each species, you have a column called `class` containing your classifications as words (e.g., "dog" or "cattle", "empty"), the function will find the appropriate `class_ID` associated with these words.
- Option 3: If you do not have your images classified, but you have all of the filenames for the images you want to classify, you can have an `input_file` csv in your with a column called "filename" and whatever other columns you would like. 
- Option 4: MLWIC2 can find the filenames of all of your images and create your input file. For this option, you need to specify your `path_prefix` which is the parent directory of your images. If you have images stored in sub-folders within this directory, specify `recursive=TRUE`, if not, you can specify `recursive=FALSE`. You also need to specify the `suffixes` (e.g., ".jpg") for your filenames so that MLWIC2 knows what types of files to look for. By default (if you don't specify anything), it will look for ".JPG" and ".jpg". 
- Option 5: If you are planning to train a model, you will want training and testing sets of images. This function will set up these files also, see `?make_input` for more details. 
 
## Step 6: Classify images using `classify`
###### <i> Shiny option: `MLWIC2::runShiny('classify')` </i>
- `path_prefix` is the absolute path where your images are stored. 
  - You can have image files in subdirectories within your `path_prefix`, but this must be relfected in your `data_info` file. For example, if you have a file located at `.../images/subdirectory1/imagefile.jpg`, and your `path_prefix=.../images/`, your filename for this image in your `data_info` file would be `subdirectory/imagefile.jpg`. 
- `data_info` is the absolute path to where your input file is stored. Check your output from `make_input`. 
- `model_dir` is the absolute path to where you stored the MLWIC2_helper_files folder in step 3.
- `log_dir` is the absolute path to the model you want to use. If you are using the built in models, it is either "species_model" or "empty_animal". If you trained a model with MLWIC2, this would be what you specified as your `log_dir_train`.  
- `os` is your operating system type. If you are using MS Windows, set `os="Windows"`, otherwise, you can ignore this argument. 
- `num_classes` is the number of species or groups of species in the model. If you are using the species_model, `num_classes=59`; if you're using the empty_animal model`num_classes=2`. If you trained your own model, this is the number that you specified.
- `top_n` is the number of guesses that classes that the model will provide guesses for. E.g., if `top_n=5`, the output will include the top 5 classes that it thinks are in the image (and the confidences that are associated with these guesses).
- `num_cores` is the number of cores on your computer that you want to use. Running `parallel::detectCores()` will tell you how many cores you have on your computer. Depending on how long you intend to run the model, you might not want to use all of your cores. For example, you could specify `num_cores = parallel::detectCores() - 2` so that you would keep two cores available for other processes. 
- See `?classify` for more options. 
 ###### If you are having trouble finding your absolute paths, you can use the shiny option `MLWIC2::runShiny('classify')` and select your files/directories from a drop down menu. Your paths will be printed on the screen so that next time you can run directly in the R console if you prefer (this is a good way to begin learning how to code). 
 - If you are using the [example images](https://github.com/mikeyEcology/MLWIC_examples/tree/master), the command would look something like this (modified based on your computer-specific paths). 
```
classify(path_prefix = "/Users/mikeytabak/Desktop/images", # path to where your images are stored
         data_info = "/Users/mikeytabak/Desktop/image_labels.csv", # path to csv containing file names and labels
         model_dir = "/Users/mikeytabak/Desktop/MLWIC2_helper_files", # path to the helper files that you downloaded in step 3, including the name of this directory (i.e., `MLWIC2_helper_files`)
         python_loc = "/anaconda2/bin/", # location of python on your computer
         save_predictions = "model_predictions.txt", # how you want to name the raw output file
         make_output = TRUE, # if TRUE, this will produce a csv with a more friendly output
         output_name = "MLWIC2_output.csv", # if make_output==TRUE, this will be the name of your friendly output file
         num_cores = 4 # the number of cores you want to use on your computer. Try runnning parallel::detectCores() to see what you have available. You might want to use something like parallel::detectCores()-1 so that you have a core left on your machine for accomplishing other tasks. 
         ) 
```

## Step 7: Update the metadata of your image files using `write_metadata` (optional)
###### <i> Shiny option: `MLWIC2::runShiny('write_metadata')` </i>
- This function uses [Exiftool software](https://exiftool.org/index.html). Exiftool is a command line tool and `write_metadata` is a wrapper that will run the software to create metadata categories and fill them with the output of `classify`. If you want to use this function you will need to first [install Exiftool following the directions here](https://exiftool.org/install.html).  
- `output_file` is the path to and file name of your output file from classify (`model_dir`+ `/` +`output_name`). Unless you deviated from the default settings, this file should be located in your `MLWIC2_helper_files` folder. 
- `model_type` is either the "species_model" or the "empty_animal" model
- You might need to specify your `exiftool_loc` if you are running on a Windows computer. This is the path to your exiftool installation. 
- Here is how I would run this function given my example call to classify above. 
```
write_metadata(output_file="/Users/mikeytabak/Desktop/MLWIC2_helper_files/MLWIC2_output.csv", # note that if you look at the classify command above, this is the [model_dir]/[output_name]
               model_type="species_model", # the type of model I used for classify
               exiftool_loc="/usr/local/bin", # location where exiftool is stored, you might not need to specify this. 
               show_sys_output = FALSE
               )
```

## Step 8: Train a new model to recognize species in your images `train`
###### <i> Shiny option: `MLWIC2::runShiny('train')` </i>
If you aren't satisfied with the accuracy of the builtin models, you can train train your own model using your images. The parameters will be similar to those for `classify`, but you will want to specify some more options based on how you want to train the model.
- `path_prefix` is the absolute path where your images are stored. 
- `data_info` is the absolute path to where your input file is stored. Check your output from `make_input`. 
- `model_dir` is the absolute path to where you stored the MLWIC2_helper_files folder in step 3.
- `num_classes` is the number of species (or groups of species) you want the model to recognize
- `architecture` is the DNN architecture. The options are c("alexnet", "densenet", "googlenet", "nin", "resnet", "vgg"). I recommend starting with "resnet" and set `depth=18`. If you get poor accuracy with this, "densenet" is another good option. 
- `depth` is the number of layers in the DNN. If you are using resnet, the options are c(18, 34, 50, 101, 152). If you are using densenet, the options are c(121, 161, 169, 201), otherwise, the depth will be automatically set for you. 
- `batch_size` is the number of images simultaneously passed to the model for training. It must be a multiple of 16. Smaller numbers will train models that are more accurate, but it will take longer to train. The default is 128.
- `log_dir_train` is the directory where you will store the model information. This will be called when you what you specify in the `log_dir` option of the `classify` function. <b>You will want to use unique names if you are training multiple models on your computer; otherwise they will be over-written</b>
- `retrain` If TRUE, the model you train will be a retraining of the model you specify in `retrain_from`. If FALSE, you are starting training from scratch. Retraining will be faster but training from scratch will be more flexible.
- `retrain_from` name of the directory from which you want to retrain the model. If you are retraining from the species model, you would set `retrain_from="species_model"`. If you need to stop training (e.g., you have to turn off your computer), you can `retrain_from` what you set as your `log_dir_train` and set your `num_epochs` to the total number you want minus the number that have completed. 
- `num_epochs` the number of epochs you want to use for training. The default is 55 and this is recommended for training a full model. But if you need to start and stop training, you can decrease this number. 
- You can read about more options by typing `?train` into the console. 




If you use this package in a publication, please site our manuscript: \
Tabak, M. A., Norouzzadeh, M. S., Wolfson, D. W., Newton, E. J., Boughton, R. K., Ivan, J. S., … Miller, R. S. (2020). [Improving the accessibility and transferability of machine learning algorithms for identification of animals in camera trap images: MLWIC2](https://www.biorxiv.org/content/10.1101/2020.03.18.997700v2). BioRxiv, 2020.03.18.997700. doi:[10.1101/2020.03.18.997700](https://www.biorxiv.org/content/10.1101/2020.03.18.997700v2)
```
@article{tabakImprovingAccessibilityTransferability2020,
  title = {Improving the Accessibility and Transferability of Machine Learning Algorithms for Identification of Animals in Camera Trap Images: {{MLWIC2}}},
  shorttitle = {Improving the Accessibility and Transferability of Machine Learning Algorithms for Identification of Animals in Camera Trap Images},
  author = {Tabak, Michael A. and Norouzzadeh, Mohammad S. and Wolfson, David W. and Newton, Erica J. and Boughton, Raoul K. and Ivan, Jacob S. and Odell, Eric A. and Newkirk, Eric S. and Conrey, Reesa Y. and Stenglein, Jennifer and Iannarilli, Fabiola and Erb, John and Brook, Ryak K. and Davis, Amy J. and Lewis, Jesse and Walsh, Daniel P. and Beasley, James C. and VerCauteren, Kurt C. and Clune, Jeff and Miller, Ryan S.},
  year = {2020},
  month = mar,
  pages = {2020.03.18.997700},
  publisher = {{Cold Spring Harbor Laboratory}},
  doi = {10.1101/2020.03.18.997700},
  journal = {bioRxiv},
  language = {en}
}
```
