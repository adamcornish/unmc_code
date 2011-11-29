#!/usr/bin/bash
echo "What is the name of the repository you want to clone? (unmc_config, unmc_code, unmc_pipelines)"
read REPO
mkdir $REPO
cd $REPO
git init
touch README
git add README
git commit -m "add README"
git remote add origin git@github.com:unmcngs/$REPO.git
git push -u origin master
