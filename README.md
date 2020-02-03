# MLWIC2: Machine Learning for Wildlife Image Classification

<b>This package is in the development stage.</b> It is similar to the [MLWIC](https://github.com/mikeyEcology/MLWIC) package. MLWIC2 contains two models: the `species_model` identifies [58 species](https://github.com/mikeyEcology/MLWIC2/blob/master/speciesID.csv) and empty images, and the `empty_animal` model distinguishes between images with animals and those that are empty. MLWIC2 also contains Shiny apps for running the functions. These can be accessed using `runShiny`. (At this point Shiny apps are not running properly on Windows machines - The paths are getting corrupted.) In the steps below, you can see <i>Shiny options</i> for some steps. This indicates that you can run these steps with Shiny apps by running the function provied. Note that when you are using Shiny apps to select directories and files, you can only navigate using the top part half of the screen. 

You need to have Anaconda Navigator installed, along with Python 3.7 (Python 3.6 will also work just as well). 


## <b>Step 1: Install the `MLWIC2` package in R</b>
```
# install devtools if you don't have it
if (!require('devtools')) install.packages('devtools')
# install MLWIC2 from github
devtools::install_github("mikeyEcology/MLWIC2")
library(MLWIC2)
```

You only need to run steps 2-4 the first time you use this package on a computer. If you have already run [MLWIC](https://github.com/mikeyEcology/MLWIC) on your computer, you can skip steps 2 and 4

## <b>Step 2: Install TensorFlow (version 1.14) on your computer.</b>
Really any version of tensorflow between 1.8 and 2.0 will do. \
The function `tensorflow` will do this on Macintosh and Linux machines, but the installation of this software is inconsistent. If you have trouble using our function or you are using a Windows computer, you can do this independently by following the directions [here](https://www.tensorflow.org/install/). 

## <b>Step 3: Download the [MLWIC2_helper_files folder from this link](https://drive.google.com/file/d/18lq__3ZAjzY0bpkXN3c6TQv78WMkP--c/view?usp=sharing).</b> 
Unzip the folder and then store this folder in a location that makes sense on your computer (e.g., Desktop). Note the location, as you will specify this as `model_dir` when you run the functions `classify`, `make_output`, and `train`. (optional) If you want to check md5sums for this file, the value should be `403c3b46ae17b6d1fa1fe687b0f1c4d3`. 

## <b>Step 4: Setup your environment for using `MLWIC` using the function `setup`</b>
###### <i> Shiny option: `MLWIC2::runShiny('setup')` </i>
- `python_loc` is the location of Python on your computer. On Macs, it is often in the default-you can determine the location by opening a terminal window and typing `which python`. In Windows you can open your command prompt and type `where python`. 
- If you already have a conda environment called "r-reticulate" with Python packages installed, you can specify `r_reticulate = TRUE`; if you don't know what this means, leave this argument as the default by not specifying it. \
- This function installs several necessary Python packages. Running this function will take a few minutes. You may see some errors when you run `setup` - you can ignore these; if there are problems with the installation, whey will become apparent when you run `classify`. 

###### Before running models on your own data, I recommend you try running using the [example  provided](https://github.com/mikeyEcology/MLWIC_examples/tree/master). 

## <b> Step 5: Create a properly formatted input file using `make_input`</b>
###### <i> Shiny option: `MLWIC2::runShiny('make_input')` </i>
 - Option 1: If you have labels for your images and you want to test the model on your images (set `images_classified=TRUE`), you need to have an `input_file` csv that has at last two columns and one of these must be "filename" and the other must be either "class" or "class_ID" depending on:
   - Use `class` If you have your classifications as words (e.g., "dog" or "cattle", "empty"), the function will find the appropriate `class_ID` associated with these words. 
   - Use `class_ID` if you found the class_ID numbers for each image in [this table](https://github.com/mikeyEcology/MLWIC2/blob/master/speciesID.csv) and put them in this column. 
 - Option 2: If you do not have your images classified, but you have all of the filenames for the images you want to classify, you can have an `input_file` csv in your with a column called "filename" and whatever other columns you would like. 
 - Option 3: MLWIC2 can find the filenames of all of your images and create your input file. For this option, you need to specify your `path_prefix` which is the parent directory of your images. If you have images stored in sub-folders within this directory, specify `recursive=TRUE`, if not, you can specify `recursive=FALSE`. You also need to specify the `suffixes` (e.g., ".jpg") for your filenames so that MLWIC2 knows what types of files to look for. By default (if you don't specify anything), it will look for ".JPG" and ".jpg". 
 - Option 4: If you are planning to train a model, you will want training and testing sets of images. This function will set up these files also, see `?make_input` for more details. 
 
## Step 6: Classify images using `classify`
###### <i> Shiny option: `MLWIC2::runShiny('classify')` </i>
 - `path_prefix` is the absolute path where your images are stored. 
 - `data_info` is the absolute path to where your input file is stored. Check your output from `make_input`. 
 - `model_dir` is the absolute path to where you stored the MLWIC2_helper_files folder in step 3.
 - `log_dir` is the absolute path to the model you want to use. If you are using the built in models, it is either "species_model" or "empty_animal". If you trained a model with MLWIC2, this would be what you specified as your `log_dir_train`.  
 - `os` is your operating system type. If you are using MS Windows, set `os="Windows"`, otherwise, you can ignore this argument. 
 - `num_classes` is the number of species or groups of species in the model. If you are using the species_model, `num_classes=59`; if you're using the empty_animal model`num_classes=2`. If you trained your own model, this is the number that you specified.
 - `top_n` is the number of guesses that classes that the model will provide guesses for. E.g., if `top_n=5`, the output will include the top 5 classes that it thinks are in the image (and the confidences that are associated with these guesses).
 - See `?classify` for more options. 
 ###### If you are having trouble finding your absolute paths, you can use the shiny option `MLWIC2::runShiny('classify')` and select your files/directories from a drop down menu. Your paths will be printed on the screen so that next time you can run directly in the R console if you prefer. 
 - If you are using the [example images](https://github.com/mikeyEcology/MLWIC_examples/tree/master), the command would look something like this (modified based on your computer-specific paths). 
```
classify(path_prefix = "/Users/mikeytabak/Desktop/images", # path to where your images are stored
         data_info = "/Users/mikeytabak/Desktop/image_labels.csv", # path to csv containing file names and labels
         model_dir = "/Users/mikeytabak/Desktop/MLWIC2_helper_files", # path to the helper files that you downloaded in step 3
         python_loc = "/anaconda2/bin/", # location of python on your computer
         save_predictions = "model_predictions.txt", # how you want to name the raw output file
         make_output = TRUE, # if TRUE, this will produce a csv with a more friendly output
         output_name = "MLWIC2_output.csv", # if make_output==TRUE, this will be the name of your friendly output file
         num_cores = 4 # the number of cores you want to use on your computer. Try runnning parallel::detectCores()
         ) 
```

This package will be associated with a new publication, but for now, please cite this manuscript if you use this pacakge: \
Tabak, M. A., M. S. Norouzzadeh, D. W. Wolfson, S. J. Sweeney, K. C. VerCauteren, N. P. Snow, J. M. Halseth, P. A. D. Salvo, J. S. Lewis, M. D. White, B. Teton, J. C. Beasley, P. E. Schlichting, R. K. Boughton, B. Wight, E. S. Newkirk, J. S. Ivan, E. A. Odell, R. K. Brook, P. M. Lukacs, A. K. Moeller, E. G. Mandeville, J. Clune, and R. S. Miller. (2019). [Machine learning to classify animal species in camera trap images: Applications in ecology](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13120). <i>Methods in Ecology and Evolution</i> 10(4): 585-590.
