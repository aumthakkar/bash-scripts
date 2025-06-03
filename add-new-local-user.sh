#!/bin/bash 
########################################################################
# Author:  Pranav Thakkar
# Date:  Wed 28 May 08:31:12 BST 2025
# Description:  Add a local user w/o prompts and self generated pwds
# Modified:  Wed 28 May 08:31:12 BST 2025
########################################################################

if [[ ${UID} -ne 0 ]]; then
  echo 'Please logon as root equivalent to run this script, Bye!' >&2
  exit 1
fi

# Provide Usage statement

usage() {
  echo "Usage: ${0} LOGIN_NAME [User_Desc].." >&2
  exit 1 
}

# Show Usage statement if user does not provide any argument
if [[ "${#}" -lt 1 ]]; then
  usage
fi


# Parse the Command to get the username and the comment part
USER=${1}
shift
COMMENT=${@}

# Create the Password
PWD=$(date +%s%N | sha256sum | head -c8)
SPEC_CHAR=$(echo '±!@£$%^&*()_+' | fold -w1 | shuf | head -c1)
PASSWD=${PWD}${SPEC_CHAR}

# Create the User
useradd -c "${COMMENT}" -m ${USER}

# Inform if the User could not be created
if [[ ${?} -ne 0 ]]; then
  echo 'User could not be created, Please inform Admin' >&2
  exit 1
fi

echo "Creating user: ${USER}..."
echo "User: '${USER}' created"

# Add the Password to the User
echo ${PASSWD} | passwd --stdin ${USER}
 
# Inform if the password could not be set
if [[ ${?} -ne 0 ]]; then
  echo 'User Password could not be set, Please inform Admin' >&2
  exit 1
fi

# Force the password to expire during the first login
passwd -e ${USER}

# Inform the Operator about User Creation details
echo "User: '${USER}' with a password of '${PASSWD}' has been created on System: $(hostname)"
exit 0
echo


 
