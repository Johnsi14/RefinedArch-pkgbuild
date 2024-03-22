#!/bin/bash

# (-p builds one package $arg  -a builds all packages)
# (-l builds the package local -p pushes the package to repo)
# (-t move packages from testing to live -d Pushes it directly to Repo)


# cd into directory 
# build package
# delete the pkg and src directory (made by the -c flag) 
# remove files that are more than 14 days old if there is one or more file
# check if folder has more than 4 files.
# remove oldest file and then recheck
# move the pkg.tar.zst file into the right folder
# rebuild the packagebase via script placed in the repo folder
# push the package to the git folder