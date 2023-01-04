#!/bin/bash

# Set the backup and app data directories
backup_dir="/opt/backups"
app_data_dir="/opt/appdata"

# Set the mount point
mount="idrive:backups"

# Array to store the file names
declare -a files

# Read all file names in the mount point
# and store them in the array
while read -r line; do
  files+=("$line")
done < <(rclone lsf "$mount")

# Display menu options for each file
PS3='Select a file to restore: '
select file in "${files[@]}"; do
  # If the file name is not empty, break out of the loop
  if [[ -n "$file" ]]; then
    break
  fi
done

# Get the file name without the extension
container_name="${file%.*.*}"

# Ask if the restore should be local or remote
read -p "Local or remote restore? [l/r] " restore_type

# If the restore is local and the file exists, untar the file in the app data directory
# and start the docker container
if [[ "$restore_type" == "l" && -f "$backup_dir/$file" ]]; then
  echo "Extracting $file in $app_data_dir..."
  tar -xvf "$backup_dir/$file" -C "$app_data_dir" &>/dev/null
  cd "$app_data_dir/$container_name"
  echo "Finally, restoring $container_name!"
  docker-compose up -d 
# If the restore is local and the file does not exist, prompt the user to either select
# a remote restore or cancel
elif [[ "$restore_type" == "l" && ! -f "$backup_dir/$file" ]]; then
  read -p "File does not exist. Select 'r' for remote restore or 'c' to cancel: " choice
  if [[ "$choice" == "r" ]]; then
    restore_type="r"
  else
    exit
  fi
fi

# If the restore is remote, use rclone to copy the file
# to the app data directory and untar it there, then start the
# docker container
if [[ "$restore_type" == "r" ]]; then
  echo "Copying $file from $mount to $backup_dir..."
  rclone copy "$mount/$file" "$backup_dir"
  echo "Extracting $file in $app_data_dir..."
  tar -xvf "$backup_dir/$file" -C "$app_data_dir" &>/dev/null
  cd "$app_data_dir/$container_name"
  echo "Finally, restoring $container_name!"
  docker-compose up -d
fi
