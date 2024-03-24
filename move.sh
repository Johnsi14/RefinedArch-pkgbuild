#!/usr/bin/env bash

cd ..

print_whould() {
    printf "\033[0;34m@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
    # shellcheck disable=SC2059
    printf "The Script whould $2: \n$1\n"
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n\033[0m"
}

#Remove the old Files
#rm -f RefinedArch_repo/x86_64/"$1"*
wd=$(ls RefinedArch_repo/x86_64/"$1"*)
print_whould "$wd" "Delete"

#Move the Files into the Repo
#mv RefinedArch_repo_testing/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst RefinedArch_repo/x86_64/
#mv RefinedArch_repo_testing/x86_64/"$1"/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst.sig RefinedArch_repo/x86_64/
wd=$(ls RefinedArch_repo_testing/x86_64/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst)
print_whould "$wd" "Move into Repo from Testing"
wd=$(ls RefinedArch_repo_testing/x86_64/"$1"-*[0-9]-*[0-9]-*.pkg.tar.zst.sig)
print_whould "$wd" "Move into Repo from Testing"

#
# Commiting to server
#

cd RefinedArch_repo || exit
./update_db.sh

git pull

git add .

git commit -m "Automated Update" -m "New Packages from Testing:: $1"
cd ..

cd RefinedArch_repo_testing || exit
./update_db.sh

git pull

git add .

git commit -m "Automated Update" -m "New Packages from PKGBUILD:: $1"
cd ..

print_done "To push the Changes to Github run push.sh"
