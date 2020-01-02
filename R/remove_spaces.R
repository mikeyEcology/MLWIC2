
# mac/linux remove spaces from file names
#find . -type f -name "* *" -exec bash -c 'mv "$0" "${0// /}"' {} \;
# this will work recursively if the folder names don't contain spaces

# this will work on folders and file names 
#system("/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"")
#"brew install rename"
#"find . -depth -name '* *' -execdir rename 's/ /_/g' '{}' \;"
