#!/bin/bash
#
# RefinedArch
# https://github.com/Johnsi14/RefinedArch
# This builds Packages and signs them and then auto moves them to the testing and normal Repo

# done(-p/package builds one package asks for the package/packages  -a builds all packages -af force Rebuilds all the packages)
# done(-l builds the package local -g pushes the package to repo)
# (-t move packages from testing to repo -d Pushes it directly to Repo (Use only when direly needed max cause Script to not work) -nt Indicates that is has no Testing Repo)
# done(-v Prints the info in the Cooler Style -nv Prints the info in the Shorter Style)

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

print_whould() {
    printf "\033[0;34m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
    # shellcheck disable=SC2059
    printf "The Script whould $2: \n$1\n"
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n\033[0m"
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

    #Only add Packages which need to be updated to $packages
    for p in "${all_pkg[@]}"; do
        args=$(check_version "$p")
        if [[ $args == *"pt"* ]] || [[ $args == *"tr"* ]] || [[ $args == *"pd"* ]]; then
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

#Checks all Packages
#for f in "${packages[@]}"; do
#    pack=$(awk -F/ '{print $1}' <<<"$f")
#    ./check.sh "$pack"
#done

print_done "All PKGBUILDS are Good"

build_pkg() {
    cd x86_64/"$1"
    makepkg -f --sign
    print_done "Built the $1 Package"
    cd ../../
}

#Builds all Packages
#for f in "${packages[@]}"; do
#    pack=$(awk -F/ '{print $1}' <<<"$f")
#    build_pkg "$pack"
#done

#/home/jonsi/RefinedRepo/RefinedArch_pkgbuild
pwd

print_done "Buildt all Packages"

#If The Packages are only locally needed exit the Script
if [[ "$scope" == "-l" ]]; then
    exit 0
fi

pr_packages=()
pt_packages=()
tr_packages=()

move_pr() {
    #Remove the old Files
    rm -f RefinedArch_repo/x86_64/"$1"*
    #wd=$(ls RefinedArch_repo/x86_64/"$1"*)
    #print_whould "$wd" "Delete"

    #Move the Files into the Repo
    mv RefinedArch_pkgbuild/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst RefinedArch_repo/x86_64/
    mv RefinedArch_pkgbuild/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst.sig RefinedArch_repo/x86_64/
    wd=$(ls RefinedArch_pkgbuild/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst)
    pkgnr=$(awk -F/ '{print $4}' <<<"$wd" | awk -F. '{print $1}')
    pr_packages+=("$pkgnr")
    #print_whould "$wd" "Move into Repo from Package"
    #wd=$(ls RefinedArch_pkgbuild/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst.sig)
    #print_whould "$wd" "Move into Repo from Package"
}

move_pt() {
    #Remove the old Files
    rm -f RefinedArch_repo_testing/x86_64/"$1"*
    #wd=$(ls RefinedArch_repo_testing/x86_64/"$1"*)
    #print_whould "$wd" "Delete"

    #Move the Files into the Repo
    mv RefinedArch_pkgbuild/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst RefinedArch_repo_testing/x86_64/
    mv RefinedArch_pkgbuild/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst.sig RefinedArch_repo_testing/x86_64/
    wd=$(ls RefinedArch_pkgbuild/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst)
    pkgnr=$(awk -F/ '{print $4}' <<<"$wd" | awk -F. '{print $1}')
    pt_packages+=("$pkgnr")
    #print_whould "$wd" "Move into Testing from Package"
    #wd=$(ls RefinedArch_pkgbuild/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst.sig)
    #print_whould "$wd" "Move into Testing from Package"

}

move_tr() {
    #Remove the old Files
    rm -f RefinedArch_repo/x86_64/"$1"*
    #wd=$(ls RefinedArch_repo/x86_64/"$1"*)
    #print_whould "$wd" "Delete"

    #Move the Files into the Repo
    mv RefinedArch_repo_testing/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst RefinedArch_repo/x86_64/
    mv RefinedArch_repo_testing/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst.sig RefinedArch_repo/x86_64/
    wd=$(ls RefinedArch_repo_testing/x86_64/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst)
    pkgnr=$(awk -F/ '{print $4}' <<<"$wd" | awk -F. '{print $1}')
    tr_packages+=("$pkgnr")
    #print_whould "$wd" "Move into Repo from Testing"
    #wd=$(ls RefinedArch_repo_testing/x86_64/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst.sig)
    #print_whould "$wd" "Move into Repo from Testing"

}

make_msg_pr() {
    for x in "${pr_packages[@]}"; do
        # shellcheck disable=SC2059
        printf " $x "
    done
}

make_msg_pt() {
    for x in "${pt_packages[@]}"; do
        # shellcheck disable=SC2059
        printf " $x "
    done
}

make_msg_tr() {
    for x in "${tr_packages[@]}"; do
        # shellcheck disable=SC2059
        printf " $x "
    done
}

cd ..

if [[ "$repo" == "-nt" ]]; then
    for f in "${packages[@]}"; do
        pack=$(awk -F/ '{print $1}' <<<"$f")
        move_pr "$pack"
    done
elif [[ "$repo" == "-d" ]]; then
    for f in "${packages[@]}"; do
        pack=$(awk -F/ '{print $1}' <<<"$f")
        move_pr "$pack"
        move_pt "$pack"
    done
elif [[ "$repo" == "-t" ]]; then
    for f in "${packages[@]}"; do
        pack=$(awk -F/ '{print $1}' <<<"$f")
        arg1=$(awk -F/ '{print $2}' <<<"$f")
        arg2=$(awk -F/ '{print $3}' <<<"$f")
        print_done "$arg1"
        print_done "$arg2"

        if [[ "$arg1" == "tr" ]]; then
            move_tr "$pack"
        fi

        move_pt "$pack"
    done
fi

#I was to tired to do that in functions as the Script will be rewritten eventually
if [[ $repo == "-nt" ]]; then
    cd RefinedArch_repo
    ./update_db.sh

    git pull

    git add .

    git commit -m "Automated Update" -m "New Packages from PKGBUILD:: $(make_msg_pr)"
    cd ..
elif [[ $repo == "-d" ]]; then
    cd RefinedArch_repo
    ./update_db.sh

    git pull

    git add .

    git commit -m "Automated Update" -m "New Packages from PKGBUILD:: $(make_msg_pr)"
    cd ..

    cd RefinedArch_repo_testing
    ./update_db.sh

    git pull

    git add .

    git commit -m "Automated Update" -m "New Packages from PKGBUILD:: $(make_msg_pt)"
    cd ..
elif [[ $repo == "t" ]]; then
    cd RefinedArch_repo
    ./update_db.sh

    git pull

    git add .

    git commit -m "Automated Update" -m "New Packages from Testing:: $(make_msg_tr)"
    cd ..

    cd RefinedArch_repo_testing
    ./update_db.sh

    git pull

    git add .

    git commit -m "Automated Update" -m "New Packages from PKGBUILD:: $(make_msg_pt)"
    cd ..
fi

cd RefinedArch_pkgbuild

git pull

git add .

git commit -m "Automated PKGBUILD Update"

print_done "Did all the Stuff. The Script will Be updated soon"
print_done "To push the Changes to Github run push.sh"
print_done "To move a package from Testing to The Repo run ./move.sh"
