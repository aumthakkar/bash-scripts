#!/bin/bash 
########################################################################
# Author:  Pranav Thakkar
# Date:  Mon 2 Jun 15:36:23 BST 2025
# Description:  Counts the number of failed login attempts by IP address
# Modified:  Mon 2 Jun 15:36:23 BST 2025
########################################################################

<<EOF
-   This shell script displays the number of failed login attempts by IP address in a CSV file format.
-   It requires that a log_file, syslog-sample file in this case but can be any other log file too, is provided as an argument. 
    -   If the log_file is not provided, or it cannot be read, then the script will display an error message and exit   
        with a status of 1.
        -    All messages associated with this event will be displayed on standard error.
-   Counts the number of failed login attempts by IP address.
    -   If there are any IP addresses with more than 10 failed login attempts, the number of attempts made and the IP address 
        from which those attempts were made, will be displayed in a CSV file format
EOF


LOG_FILE="${1}"
LIMIT=10

# Usage statement if user takes wrong option(s).
usage() {
  echo "Usage: ./${0} FILENAME" >&2
  exit 1  
}

# Requires that a file be provided as an arg or else provide help.
if [[ ! -f "${LOG_FILE}" ]]; then 
  usage
fi

# Display the CSV header.
echo -e 'COUNT,\tIP_ADDRESS'

# Loop thro the list of failed login attempts and corresponding IP addresses and display thatin CSV format.
grep -i 'failed' "${LOG_FILE}" | awk '{print $(NF-3)}' | sort | uniq -c | sort -n | while read -r COUNT IP; do
  if [[ "${COUNT}" -gt "${LIMIT}" ]]; then
    echo -e "${COUNT},\t${IP}"
  fi
done

exit 0

