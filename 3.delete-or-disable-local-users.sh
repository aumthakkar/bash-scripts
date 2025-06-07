#!/bin/bash 
#############################################################################
# Author:  Pranav Thakkar
# Date:  Fri 30 May 09:41:14 BST 2025
# Description: Disables, deletes, and/or archives users on the local system
# Modified:  Fri 30 May 09:41:14 BST 2025
#############################################################################

<<EOF
-   This script by default disables non-system user Linux account(s) but will delete it if -d option is taken.
    - Before deleting the user account it can archive the user's home directory with option -a.
    - It only deletes the user account if the user archive is successful.
-   Enforces that it be executed with superuser (root) privileges.
-   Provides a usage statement much like you would find in a man page if the user does not supply an account name on the 
    command line and returns an exit status of 1.
    -    All messages associated with this event will be displayed on standard error.
-   Disables (expires/locks) account(s) by default, or deletes account(s) upon choosing the delete (-d) option
-   Allows the user to specify the following options:
    -   -d Deletes accounts instead of disabling them.
    -   -r Removes the home directory associated with the account(s).
    -   -a Creates an archive of the home directory associated with the accounts(s) and stores the archive in the /
           archives directory.  
    -   Any other option will cause the script to display a usage statement and exit with an exit status of 1.
        -   All messages associated with this event will be displayed on standard error.
-   Accepts a list of usernames as arguments. At least one username is required or the script will display a usage     
    statement much like you would find in a man page and return an exit status of 1.
-   Refuses to disable or delete any accounts that have a UID less than 1000 (system accounts)
-   Informs the user if the account was not able to be disabled, deleted, or archived for some reason.
-   Displays the username and any actions performed against the account.
EOF

ARCHIVE_DIR="/archive"

# Ensure user running with root privileges
if [[ ${UID} -ne 0 ]]; then
  echo 'Please use root privileges to run this script, Bye!' >&2
  exit 1
fi

# Provide Usage statement
usage() {
  echo "Usage: ./${0} [-dra] USER_NAME [USER_NAME]... " >&2
  echo 'Disable a local Linux Account' >&2
  echo ' -d deletes the user account instead of just disabling that account(s)' >&2
  echo ' -r removes the user home directory when deleting the user account(s)' >&2
  echo ' -a archives the associated user home directory' >&2
}

# Parse the options
while getopts dra OPTION; do
  case ${OPTION} in
    d) DELETE_USER='true' ;;
    r) REMOVE_HOME_DIR='-r' ;;
    a) ARCHIVE='true' ;;
    ?) usage ;;
  esac
done

# Remove the Options while leaving the arguments
shift "$(( OPTIND -1 ))"

# Inform Usage if user has not passed any username argument on command line
if [[ ${#} -lt 1 ]]; then
  usage
  exit 1
fi

# Remaining arguments on cmd line are the user account names to be created 
USERS="${@}"

# Loop through all the usernames supplied as arguments
for USER in ${USERS}; do
  # Check and inform that user account won't be exercised if its a system account
  USERID="$(id -u "$USER")"
  if [[ ${USERID} -lt 1000 ]]; then
    echo 'Cannot exercise this user account as its a system account!, Bye' >&2
    exit 1 
  fi

  # Exercise the Archive Option
  if [[ "${ARCHIVE}" = 'true' ]]; then
    # Make sure the Archive directory exists
    if [[ ! -d "${ARCHIVE_DIR}" ]]; then
      echo "Creating Archive directory: ${ARCHIVE_DIR}"
      mkdir -p /archive
    # Inform if Archive directory could not be created
      if [[ ${?} -ne 0 ]]; then
        echo "Archive directory ${ARCHIVE_DIR} could not be created, pls inform Admin" >&2
        exit1
      fi
    fi
  fi
      
    HOME_DIR="/home/${USER}"
    ARCHIVE_FILE="${ARCHIVE_DIR}/${USER}.tgz"

    if [[ -d "${HOME_DIR}" ]]; then      
      echo "Archiving ${USER}'s home directory to ${ARCHIVE_FILE}" 
      # Run the backup command
      tar -cvzf "${ARCHIVE_FILE}" "${HOME_DIR}" > /dev/null    

    # Check to see if the backup was successful
      if [[ ${?} -eq 0 ]]; then
        echo "${USER}'s home dir archived to ${ARCHIVE_FILE}"
        BACKUP_COMPLETE='true'
      else
        echo "${USER}'s home directory could not be backed up, pls inform Admin" >&2
      fi  
    else
      echo "${HOME_DIR} does not exist" >&2
      BACKUP_NOT_REQD='true'
  fi

  # Exercise the Delete user option ensuring that user backup is complete
  if [[ "${DELETE_USER}" = 'true' && "${BACKUP_COMPLETE}" = 'true' || "${DELETE_USER}" = 'true' && "${BACKUP_NOT_REQD}" = 'true' ]]; then

    # Run the userdel command
    userdel "${REMOVE_HOME_DIR}" "${USER}"

    # Check to see if the delete user command was successful
    if [[ ${?} -ne 0 ]]; then
      echo "User: ${USER} could not be deleted, pls inform Admin" >&2
      exit 1
    else
      echo "User: ${USER} deleted"
    fi

  else

    # Run the Disable User command which this script runs by default for the users specified 
    chage -E 0 "${USER}"

    # Check to see if the disable user command was successful
    if [[ ${?} -ne 0 ]]; then
      echo "User: ${USER} could not be disabled, pls inform Admin" >&2
      exit 1
    else
      echo "User: ${USER} disabled"
    fi
  fi
done
exit 0
