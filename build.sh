#!/bin/bash
#
# RefinedArch
# https://github.com/Johnsi14/RefinedArch
# This builds Packages and signs them and then auto moves them to the testing and normal Repo

# (-p/package builds one package asks for the package/packages  -a builds all packages -af force Rebuilds all the packages)
# (-l builds the package local -g pushes the package to repo)
# (-t move packages from testing to repo -d Pushes it directly to Repo (Use only when direly needed) -nt Indicates that is has no Testing Repo)
# (-v Prints the info in the Cooler Style -nv Prints the info in the Shorter Style)

#The Standart arguments to be Used
package="-a"
scope="-g"
repo="-t"
verbose="-v"

#Makes the Script Fail on Error
set -euo pipefail

print_info() {
    if [[ "$verbose" == "-v" ]]; then
        echo "####################################################################################################"
        echo "$1"
        echo "####################################################################################################"
    else
        echo "$1"
    fi
}

print_done() {
    if [[ "$verbose" == "-v" ]]; then
        printf "\033[0;32m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
        # shellcheck disable=SC2059
        printf "$1\n"
        printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n\033[0m"
    else
        # shellcheck disable=SC2059
        printf "\033[0;32m$1\n\033[0m"
    fi

}

print_error() {
    if [[ "$verbose" == "-v" ]]; then
        echo "####################################################################################################" >&2
        echo "$1" >&2
        echo "####################################################################################################" >&2
    else
        echo "$1" >&2
    fi

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
    -v) verbose="-v" ;;
    -nv) verbose="-nv" ;;
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

version_compare() {
    #1 == Is Newer Version //  0 == Same  //  Older = Error
    if [[ $1 -gt $3 ]]; then
        echo "1"
    elif [[ $1 -eq $3 ]] && [[ $2 -gt $4 ]]; then
        echo "1"
    elif [[ $1 -eq $3 ]] && [[ $2 -eq $4 ]]; then
        echo "0"
    else
        print_error "The $5 PKGBUILD is lower than the Repo or Testing Version"
    fi
}

check_version() {
    pkgbuild_version=$(grep -oP '(?<=pkgver=).*' ./x86_64/"$1"/PKGBUILD)
    pkgbuild_release=$(grep -oP '(?<=pkgrel=).*' ./x86_64/"$1"/PKGBUILD)

    repo_version=$(find ../RefinedArch_repo/x86_64 -type f | grep "$1" | sed -n '1p' | awk -F- '{print $(NF-2)}')
    repo_release=$(find ../RefinedArch_repo/x86_64 -type f | grep "$1" | sed -n '1p' | awk -F- '{print $(NF-1)}')

    pr=$(version_compare "$pkgbuild_version" "$pkgbuild_release" "$repo_version" "$repo_release" "$1")

    if [[ "$repo" != "-nt" ]]; then
        testing_version=$(find ../RefinedArch_repo_testing/x86_64 -type f | grep "$1" | sed -n '1p' | awk -F- '{print $(NF-2)}')
        testing_release=$(find ../RefinedArch_repo_testing/x86_64 -type f | grep "$1" | sed -n '1p' | awk -F- '{print $(NF-1)}')

        pt=$(version_compare "$pkgbuild_version" "$pkgbuild_release" "$testing_version" "$testing_release" "$1")
        tr=$(version_compare "$testing_version" "$testing_release" "$repo_version" "$repo_release" "$1")
    fi

    if [[ "$repo" == "-t" ]]; then
        #Check Which is newer and print it if it is getting updated but checks also the testing Repo
        if [[ "$tr" == "1" ]]; then
            printf "tr/"
        elif [[ "$tr" == "0" ]]; then
            printf "nr/"
        fi

        if [[ "$pt" == "1" ]]; then
            printf "pt/"
        elif [[ "$pt" == "0" ]]; then
            printf "nt/"

        fi

        exit
    else
        #Check Which is newer and print it if it is getting updated
        if [[ $pr == "1" ]]; then
            printf "pd/"
        else
            printf "nd/"
        fi
    fi

    # Types of Transfer  pd: move package to repo  pt: move package to testing n: dont do anything pt: move to Testing td: Move testing to direct
}

packages=()

if [[ $package == "-p" ]]; then
    print_info "What Packages to Update"
    read -r -a packages
elif [[ $package == "-af" ]]; then
    pkg=$(find x86_64 -maxdepth 1 -mindepth 1 -type d | awk -F/ '{printf "%s ", $2}')
    read -r -a packages <<<"$pkg"
elif [[ $package == "-a" ]]; then
    pkg=$(find x86_64 -maxdepth 1 -mindepth 1 -type d | awk -F/ '{printf "%s ", $2}')
    all_pkg=()
    read -r -a all_pkg <<<"$pkg"

    for p in "${all_pkg[@]}"; do
        args=$(check_version "$p")
        #print_info "The package $p returns $args"
        if [[ $args == *"pt"* ]] || [[ $args == *"tr"* ]] || [[ $args == *"pd"* ]]; then
            #print_done "$p Package is getting updated"
            packages+=("$p/$args")
        fi
    done
fi

if [[ ${#packages[@]} -lt 0 ]]; then
    print_error "No Packages Updating"
fi

print_info "The following packages will be updated:"

for f in "${packages[@]}"; do
    pack=$(awk -F/ '{print $1}' <<<"$f")
    echo "$pack"
done

for f in "${packages[@]}"; do
    pack=$(awk -F/ '{print $1}' <<<"$f")
    ./check.sh "$pack"
done

print_info "All PKGBUILDS are Good"

build_pkg() {
    cd x86_64/"$1"
    makepkg -c -f --sign
    print_info "Built the $1 Package"
    cd ../../
}

for f in "${packages[@]}"; do
    pack=$(awk -F/ '{print $1}' <<<"$f")
    build_pkg "$pack"
done

#gets List of all Packages by checking what version is on the repo and or live repo

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
