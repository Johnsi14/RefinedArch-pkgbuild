#!/usr/bin/env bash

if [ -d ../RefinedArch_repo ]; then
    cd ../RefinedArch_repo || exit

    git push
fi
if [ -d ../RefinedArch_repo_testing ]; then
    cd ../RefinedArch_repo_testing || exit

    git push
fi

cd ../RefinedArch_pkgbuild || exit

git push
