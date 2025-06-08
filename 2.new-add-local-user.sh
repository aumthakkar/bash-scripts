#!/bin/bash 
#####################################################################################
# Author:  Pranav Thakkar
# Date:  Wed 28 May 08:31:12 BST 2025
# Description:  Add local user and self generated pwd and displays minimal messages
# Modified:  Wed 28 May 08:31:12 BST 2025
#####################################################################################

<<EOF
-   This script creates new Linux accounts on the system by taking the user account to be created as cmd argument.
-   The script enforces that it be executed with superuser (root) privileges.
-   Uses the first argument provided on the command line as the username for the account. 
    -   Any remaining arguments on the command line will be treated as the comment for the account.
-   It automatically generates a password (with special character, if required) for the new account.
-   If the account is not created, the script returns an exit status of 1.  
    -   All messages associated with this event will be displayed on standard error.
EOF


# Inform user to use root equivalent profile to run this script.
if [[ ${UID} -ne 0 ]]; then
  echo 'Please logon as root equivalent to run this script, Bye!' >&2
  exit 1
fi

# Usage statement if user takes wrong option(s).
usage() {
  echo "Usage: ./${0} LOGIN_NAME [User_Desc].." >&2
  exit 1 
}

# Show Usage statement if user does not provide any argument.
if [[ "${#}" -lt 1 ]]; then
  usage
fi


# Parse the Command to get the username and the comment part.
USER="${1}"
shift
COMMENT="${@}"

# Password w/o special character
PWD=$(date +%s%N | sha256sum | head -c8)

# Create a new special character if required for the password
SPEC_CHAR=$(echo '±!@£$%^&*()_+' | fold -w1 | shuf | head -c1)

# Final password
PASSWD=${PWD}${SPEC_CHAR}

# Create the User
echo "Creating user: ${USER}..." > /dev/null
useradd -c "${COMMENT}" -m "${USER}" &> /dev/null

# Inform if the User could not be created
if [[ ${?} -ne 0 ]]; then
  echo 'User could not be created, Please inform Admin' >&2
  exit 1
fi

# Add the Password to the User
echo "${PASSWD}" | passwd --stdin "${USER}" &> /dev/null
 
# Inform if the password could not be set
if [[ ${?} -ne 0 ]]; then
  echo 'User Password could not be set, Please inform Admin' >&2
  exit 1
fi

# Force the password to expire during the first login
passwd -e "${USER}" &> /dev/null

# Inform the Operator about User Creation details
echo "User: '${USER}' with a password of '${PASSWD}' has been created on System: $(hostname)"
exit 0
echo


 
