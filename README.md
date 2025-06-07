# bash-scripts
Script purpose and usage for all 5 bash scripts in this repo are listed below: 

1. add-local-user.sh script:
   ========================= 
-   This script creates new Linux accounts on the system 
-   It enforces that this script be executed with superuser (root) privileges.
-   It prompts the person who executed the script to enter the username (login), the real name for person who will be using the 
    account, and the initial password for the account.
-   Once account is created, it displays the username, password, and host where the account was created.

2. new-add-local-users.sh:
   =======================
-   This script creates new Linux accounts on the system by taking the user account to be created as cmd argument.
-   The script enforces that it be executed with superuser (root) privileges.
-   Uses the first argument provided on the command line as the username for the account. 
    -   Any remaining arguments on the command line will be treated as the comment for the account.
-   It automatically generates a password (with special character, if required) for the new account.
-   If the account is not created, the script returns an exit status of 1.  
    -   All messages associated with this event will be displayed on standard error.

3.  delete-or-disable-local-users.sh:
    =================================
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

4.  show-attackers.sh:
    ==================
-   This shell script displays the number of failed login attempts by IP address in a CSV file format.
-   It requires that a log_file is provided as an argument. 
    -   If the log_file is not provided, or it cannot be read, then the script will display an error message and exit   
        with a status of 1.
        -    All messages associated with this event will be displayed on standard error.
-   Counts the number of failed login attempts by IP address.
    -   If there are any IP addresses with more than 10 failed login attempts, the number of attempts made and the IP address 
        from which those attempts were made, will be displayed in a CSV file format

5.  run-remote-cmds.sh:
    ===================
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



