#!/usr/bin/env bash

git pull

git add .

echo "##########################################"
echo "Enter your Commit Message"
echo "##########################################"

read -r input

git commit -m "Manual Push: $input"

git push -u origin

echo "##########################################"
echo "Commit and Push Completed"
echo "##########################################"
