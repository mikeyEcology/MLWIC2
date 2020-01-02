#' Install TensorFlow for use with \code{MLWIC}
#'
#' \code{MLWIC} requires an installation of tensorflow that can be used by Python.
#'  You need to use this before using \code{classify} or \code{train}. If this is your first time using
#'  this function, you should see additional documentation at https://github.com/mikeyEcology/MLWIC .
#'  This function will install tensorflow on Linux machines; if you are using Windows,
#'  you will need to install tensorflow on your own following the directions here:
#'  https://www.tensorflow.org/install/install_windows. I recommend using the installation with
#'  Anaconda.
#'
#'
#' @param os The operating system on your computer. Options are "Mac" or "Ubuntu".
#'  Specifying "Windows" will thrown an error because we cannot automatically install
#'  TensorFlow on Windows at this time.
#' @export

tensorflow <- function(os="Mac"){
  
  ## Check for python
  vpython <- system("pyv=\"$(python -V 2>&1)\" | echo $pyv | grep \"Python\"") ## come back to this
  
  if(vpython == TRUE){
    print("Python is installed. Installing homebrew, protobuf, pip, and tensorflow.")
    
    if(os == "Mac"){
      
      system("/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"")
      system("brew install protobuf")
      system("sudo easy_install --upgrade pip")
      system("sudo easy_install --upgrade six")
      system("sudo conda update --all")
      system("sudo pip install tensorflow==1.4")
      ## Something to validate installation, beyond this.
      #system("python import_tf.py")
      
      # I think I need to add: conda install tensorflow
      
    }else if(os == "Ubuntu"){
      system("sudo apt-get install python-pip python-dev")   # for Python 2.7
      system("pip install tensorflow==1.4")
      
      #system("python import_tf.py")
      
    }else if(os == "Windows"){
      system("pip install --upgrade pip")
      system("pip install tensorflow==1.4")
      print("Installing tensorflow on Windows is more complicated and might not work directly from R. If you have problems see https://www.tensorflow.org/install/install_windows for tensorflow installation instructions.")
      
    }else{
      print('Specify operating system - \"Mac\", \"Windows\", or \"Ubuntu\"')
    }
    
  }else{
    print("Python needs to be installed.")
  }
  
}