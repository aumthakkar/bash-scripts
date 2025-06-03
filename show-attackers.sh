#!/bin/bash 
########################################################################
# Author:  Pranav Thakkar
# Date:  Mon 2 Jun 15:36:23 BST 2025
# Description:  Counts the number of failed login attempts by IP address
# Modified:  Mon 2 Jun 15:36:23 BST 2025
########################################################################

LOG_FILE="${1}"
LIMIT=10

usage() {
  echo "Usage: ./${0} FILENAME" >&2
  exit 1  
}

# Requires that a file be provided as an arg 
if [[ ! -f ${LOG_FILE} ]]; then 
  usage
fi

# Display the CSV header
echo -e 'COUNT,\tIP_ADDRESS'

# Loop thro the list of failed login attempts and corresponding IP addresses
grep -i 'failed' syslog-sample | awk '{print $(NF-3)}' | sort | uniq -c | sort -n | while read -r COUNT IP; do
  if [[ ${COUNT} -gt ${LIMIT} ]]; then
    echo -e "${COUNT},\t${IP}"
  fi
done

exit 0

