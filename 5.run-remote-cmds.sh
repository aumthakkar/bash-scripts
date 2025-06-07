#!/bin/bash 
#################################################################################
# Author:  Pranav Thakkar
# Date:  Wed 4 Jun 14:57:45 BST 2025
# Description:  Executes args as a single cmd on every server listed in the file
# Modified:  Wed 4 Jun 14:57:45 BST 2025
#################################################################################

<<EOF
-   This script executes all arguments as a single command on every server listed in the ./servers file by default.
-   It executes the provided command(s) as the user executing the script.
-   Enforces that it be executed without superuser (root) privileges. 
    -   If the user wants the remote commands executed with superuser (root) privileges, they are to specify the -s 
        option.
-   Allows the user to specify the following options:
    -   -f FILE  This allows the user to override the default file of ./servers. This way they can create their 
            own list of servers execute commands against that list.
    -   -n This allows the user to perform a "dry run" where the commands will be displayed instead of executed. It precedes   
           each command that would have been executed with "DRY RUN: ".
    -   -s Run the command with sudo (superuser) privileges on the remote servers.
    -   -v Enable verbose mode, which displays the name of the server for which the command is being executed on.
-   Provides a usage statement much like you would find in a man page. If the user does not supply a command to run on 
    the command line and returns an exit status of 1.
    -   All messages associated with this event will be displayed on standard error.
-   Exits with an exit status of 0 or the most recent non-zero exit status of the ssh command.
EOF


SERVERS_FILE='./servers'
SSH_OPTION='-o ConnectTimeout=2'

# Usage statement if user takes wrong option(s)
usage() {
  echo "Usage: ./${0} -f FILENAME nsv 'CMD; [CMD]...'"
  echo ' -f: Provide a file containing the list of servers where this command has to run' >&2
  echo ' -n: Dry run - The command will just be displayed and not executed' >&2
  echo ' -s: Run the command with sudo privileges on the remote servers' >&2
  echo ' -v: Verbose Mode: Displays the name of the server where the command is executed' >&2
}

# Force the user to run without root privileges
if [[ "${UID}" -eq 0 ]]; then
  echo "Please run this script without sudo privileges. Bye!" >&2
  exit 1
fi

# Parse the options
while getopts f:nsv OPTION; do
  case ${OPTION} in 
    f) SERVERS_FILE=${OPTARG} ;;
    n) DRY_RUN='true' ;;
    s) SUDO='sudo' ;;
    v) VERBOSE='true' ;;
    ?) usage ;;
  esac
done

# Remove the options while just keeping the argument on
shift $(( OPTIND - 1 ))

# Anything that remains is the argument containing the command to run on remote
if [[ "${#}" -lt 1 ]]; then
  usage
fi
REMOTE_CMD="${@}"

# Make sure the SERVER_LIST file exists.
if [[ ! -e "${SERVERS_FILE}" ]]; then
	echo "Cannot open server list file ${SERVERS_FILE}." >&2
	exit 1
fi

# Expect the best, prepare for the worst.
EXIT_STATUS='0'

# Loop thro all the servers listed in the Server's file
for SERVER in $(cat "${SERVERS_FILE}"); do
  # Execute Verbose Option
  if [[ "${VERBOSE}" = 'true' ]]; then
    echo "Executing the command on ${SERVER}..."
  fi

  # Create the ssh command
  SSH_COMMAND="ssh ${SSH_OPTION} ${SERVER} ${SUDO} ${REMOTE_CMD}"

  # Display/execute the ssh command
  if [[ "${DRY_RUN}" = 'true' ]]; then
    echo "DRY_RUN: ${SSH_COMMAND}"
  else
    # Execute the command
    ${SSH_COMMAND}
    SSH_EXIT_STATUS="$?"
    # Inform the user of a non-zero exit status
    if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]; then 
      EXIT_STATUS=${SSH_EXIT_STATUS}
      echo "Execution on Server:'${SERVER}' failed with an ssh exit status of:'${EXIT_STATUS}'" >&2
      echo
    else
      echo 'ssh remote command executed successfully'
      echo
    fi
  fi   
done  
        
exit ${EXIT_STATUS}







