#!/bin/bash 
########################################################################
# Author:  Pranav Thakkar
# Date:  Tue 27 May 15:28:42 BST 2025
# Description:  Create a local user profile
# Modified:  Tue 27 May 15:28:42 BST 2025
########################################################################

# Inform the user to use root equivalent profile to run this script
if [[ ${UID} -ne 0 ]]; then
  echo 'Please login as root user equivalent to run this script, Bye!'
  exit 1
fi

# Prompt to ask the user name for login details
read -p 'Please enter the username: ' USER
read -p "Please provide user's real name: " REAL_NAME
read -p 'Please provide the password for this user: ' PASSWD

# Create the user
useradd -c "${REAL_NAME}" -m "${USER}"

# Check to see if the account was created
if [[ ${?} -ne 0 ]]; then
  echo 'The user could not be created'
  exit 1
fi

# Add the user's password
echo "${PASSWD}" | passwd --stdin "${USER}"

#Inform the user if the password could not be set
if [[ ${?} -ne 0 ]]; then
  echo 'The user password could not be added'
  exit 1
fi

# Force password change on first login
passwd -e "${USER}"


# Inform the user's about the user creation with details
echo "${USER} was created on $(hostname) with a password of ${PASSWD}"
