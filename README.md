# Backups

### Introduction
This script is designed to backup folders within a specified `appdata` directory to a specified `backups` directory and then upload them to a mount using rclone. It will also power down and start up all running docker containers, except for those specified in the `exclude_list`.

### Requirements
- The `tar` utility must be installed on the system.
- `rclone` must be installed and configured with a remote to which the backups should be uploaded.


### Usage
To use the script, make sure it is executable with `chmod +x backup.sh`, then run it with `./backup.sh`.

### Customization
There are several variables at the top of the script that can be customized to fit your specific setup:

- `appdata`: the filepath to the directory containing the folders that you want to backup.
- `backups`: the filepath to the directory where the zipped backups should be stored.
- `mount`: the filepath to the mount where the backups should be uploaded using rclone.
- `exclude_list`: an array of names of folders within the `appdata` directory that should not be backed up or have their associated docker containers stopped or started.

You may also customize the behavior of the script by modifying the commands within the for loops or the conditional statements.

---

# Restores

### Introduction
This script is designed to restore a backed up docker container from a specified mount using rclone. The user can choose to restore the container locally or remotely.

### Requirements
- The `tar` utility must be installed on the system.
- `rclone` must be installed and configured with a remote from which the backup should be restored.

### Usage
To use the script, make sure it is executable with `chmod +x restore.sh`, then run it with `./restore.sh`. The script will display a menu of the available backups on the mount and prompt the user to select one to restore or to restore all containers. If the user chooses to restore a specific container, they will then be prompted to choose a local or remote restore.

### Customization
There are several variables at the top of the script that can be customized to fit your specific setup:

- `backup_dir`: the filepath to the directory where the zipped backup should be stored after it is copied from the mount.
- `app_data_dir`: the filepath to the directory where the extracted backup should be stored.
- `mount`: the filepath to the mount from which the backup should be restored using rclone.

You may also customize the behavior of the script by modifying the commands within the conditional statements or the select loop.

---

## backup.sh
- no known improvements needed
- potential webhook
- comparing the zip size between the local and server one to check for changes. If no changes, don't upload

## restore.sh
- docker-compose up -d (DONE)
- restore all option
