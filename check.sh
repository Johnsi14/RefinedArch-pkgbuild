#!/bin/bash
#
# RefinedArch
# https://github.com/Johnsi14/RefinedArch
# This checks if all PKGBUILD files are written correctly

set -euo pipefail

cd x86_64

check_pkg() {
    if [ ! -d "$1" ]; then
        echo "Error: Package '$1' not found" >&2
        exit 1
    else
        echo "########################################"
        echo "Checking the $1 package"
        echo "########################################"
        cd "$1"
        makepkg --printsrcinfo -f
        makepkg --verifysource -f
        cd ..

        echo "########################################"
        echo "Checked the $1 package"
        echo "########################################"
    fi
}

if (("$#" == 1)); then
    check_pkg "$1"
else
    find "." -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
        check_pkg "$dir"
    done
    printf "\033[0;32m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
    printf "Checked all Pachages. Next run ./build.sh\n"
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\033[0m"
fi

cd ..

exit 0
