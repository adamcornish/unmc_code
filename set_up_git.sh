#!/usr/bin/bash

# Variables
STEPS=7
I=1

echo "[$I/$STEPS] Generate rsa key."; ((I++))
ssh-keygen -t rsa -C "adam.cornish@unmc.edu"
echo "\tid_rsa.pub is:"
cat ~/.ssh/id_rsa.pub
echo "[$I/$STEPS] Hit enter when you have entered the id_rsa.pub key into the github account (Account Settings > SSH Public Keys > Add another public key)."; ((I++))
read
echo "[$I/$STEPS] Validate rsa key by ssh-ing into github.com"; ((I++))
ssh -T git@github.com
echo "[$I/$STEPS] Git config add user name."; ((I++))
git config --global user.name "Adam Cornish"
echo "[$I/$STEPS] Git config add user name."; ((I++))
git config --global user.email "adam.cornish@unmc.edu"
echo "[$I/$STEPS] Git config add user id."; ((I++))
git config --global github.user unmcngs
echo "[$I/$STEPS] Git config add user id. Enter the token from the github website (Account Settings > Account Admin > API Token): "
read TOKEN
git config --global github.token $TOKEN
