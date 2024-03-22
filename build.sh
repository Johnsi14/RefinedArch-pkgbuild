#!/bin/bash
#
# RefinedArch
# https://github.com/Johnsi14/RefinedArch
# This builds Packages and signs them and then auto moves them to the testing and normal Repo

# (-p builds one package $arg  -a builds all packages -af force Rebuilds all the packages)
# (-l builds the package local -g pushes the package to repo)
# (-t move packages from testing to repo -d Pushes it directly to Repo -nt Indicates that is has no Testing Repo)

#The Standart arguments to be Used
package="-a"
scope="-g"
repo="-nt"

#Makes the Script Fail on Error
set -euo pipefail

print_info() {
    echo "####################################################################################################"
    echo "$1"
    echo "####################################################################################################"
}

print_done() {
    printf "\033[0;32m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
    # shellcheck disable=SC2059
    printf "$1\n"
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\033[0m"
}

print_error() {
    echo "####################################################################################################" >&2
    echo "$1" >&2
    echo "####################################################################################################" >&2
    exit 1
}

# Parse the Args
for arg in "$@"; do
    case $arg in
    -p) package="-p" ;;
    -a) package="-a" ;;
    -af) package="-af" ;;
    -l) scope="-l" ;;
    -g) scope="-g" ;;
    -t) repo="-t" ;;
    -d) repo="-d" ;;
    -nt) repo="-nt" ;;
    esac
done

print_info "Running the Script with $package $scope $repo args Set"

#checks if all folders are there
if [ -d ../RefinedArch_repo ] && [ -d ../RefinedArch_repo_testing ]; then
    print_info "All Folders are There"
elif [ -d ../RefinedArch_repo ]; then
    if ((repo == "-t")); then
        print_error "The Testing Repo does not exist"
    else
        print_info "Only the Normal repo is There"
    fi
elif [ -d ../RefinedArch_repo_testing ]; then
    print_error "Only the Testing Repo is There"
else
    print_error "No Repo does Exist"
fi

#gets List of all Packages

#functions buildpkg, movepkgtest , movepkgrepo, rebuild_dblive, autopush

# cd into directory
# build package
# delete the pkg and src directory (made by the -c flag)
# remove files that are more than 14 days old if there is one or more file
# check if folder has more than 4 files.
# remove oldest file and then recheck
# move the pkg.tar.zst file into the right folder
# rebuild the packagebase via script placed in the repo folder
# push the package to the git folder
