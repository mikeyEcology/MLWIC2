MLWIC2: Machine Learning for Wildlife Image Classification

<b>This package is in the development stage.</b> It is an improvement from the [MLWIC](https://github.com/mikeyEcology/MLWIC) package. Many aspects will run the same as MLWIC, but the trained model is now located [here](https://drive.google.com/drive/folders/1YGnHaVze7zBs_cRtgiFAgaBP_kz6xZPx?usp=sharing); you'll need to download the whole folder. While there is not yet the extensive documentation here as in the MLWIC readme, there is a lot of information in the help files which can be accessed by typing, for example, `?classify`.

To run the package you'll need to install these dependecies that are for some reason not being installed automatically:
```
packages.vec <- c("reticulate", "utils", "shiny", "shinyFiles")
if(FALSE %in% unique(is.element(packages.vec, rownames(installed.packages())))){
  install.packages(setdiff(packages.vec, rownames(installed.packages())))
}  
lapply(packages.vec, require, character.only=TRUE)
```
Then install and load the package
```
devtools::install_github("mikeyEcology/MLWIC2")
library(MLWIC2)
```

Once you have set up your environment similar to the instructions for [MLWIC](https://github.com/mikeyEcology/MLWIC), you can classify images using the Shiny app.

```
MLWIC2::runShiny('classify')
```

This package will be associated with a new publication, but for now, please cite this manuscript if you use this pacakge: \
Tabak, M. A., M. S. Norouzzadeh, D. W. Wolfson, S. J. Sweeney, K. C. VerCauteren, N. P. Snow, J. M. Halseth, P. A. D. Salvo, J. S. Lewis, M. D. White, B. Teton, J. C. Beasley, P. E. Schlichting, R. K. Boughton, B. Wight, E. S. Newkirk, J. S. Ivan, E. A. Odell, R. K. Brook, P. M. Lukacs, A. K. Moeller, E. G. Mandeville, J. Clune, and R. S. Miller. (2019). [Machine learning to classify animal species in camera trap images: Applications in ecology](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13120). <i>Methods in Ecology and Evolution</i> 10(4): 585-590.
