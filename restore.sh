#!/bin/bash

# Set the backup and app data directories
backup_dir="/opt/backups"
app_data_dir="/opt/appdata"

# Array to store the file names
declare -a files

# Read all file names in the backup directory
# and store them in the array
while read -r line; do
  files+=("$line")
done < <(find "$backup_dir" -type f -printf "%f\n")

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

# If the restore is local, untar the file in the app data directory
# and start the docker container
if [[ "$restore_type" == "l" ]]; then
  tar -xvf "$backup_dir/$file" -C "$app_data_dir"
  docker start "$container_name"
# If the restore is remote, use rclone to copy the file
# to the app data directory and untar it there, then start the
# docker container
elif [[ "$restore_type" == "r" ]]; then
  rclone copy idrive:backups/"$file" "$backup_dir"
  tar -xvf "$backup_dir/$file" -C "$app_data_dir"
  docker start "$container_name"
fi
