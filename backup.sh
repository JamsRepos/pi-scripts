#!/bin/bash

# Set filepaths as variables
appdata="/opt/appdata"
backups="/opt/backups"
mount="idrive:/backups"
exclude_list=("adguard" "uptime-kuma")

# Create the zip destination folder if it doesn't already exist
[ -d "$backups" ] || mkdir "$backups"

# Get a list of all running docker containers
running_containers=$(docker ps -q)

echo "Powering down all running docker containers, except those in the exclude list..."

# Power down all running docker containers, except those in the exclude list
if [ ! -z "$running_containers" ]; then
  for container in $running_containers; do
    if [[ ! " ${exclude_list[@]} " =~ " $(docker inspect --format='{{.Name}}' "$container" | tr -d '/') " ]]; then
      docker stop "$container"
      echo "Powered down container: $container"
    fi
  done
fi

echo "Zipping all of the folders within the appdata folder, except those in the exclude list..."

# Zip all of the folders within the appdata folder, except those in the exclude list
for folder in "$appdata"/*; do
  if [ -d "$folder" ] && [[ ! " ${exclude_list[@]} " =~ " $(basename "$folder") " ]]; then
    zip_file="$backups/$(basename "$folder").tar.gz"
    echo "Starting to archive $(basename "$folder")"
    tar -czf "$zip_file" -C "$appdata" "$(basename "$folder")"
    echo "Sucessfully archived $(basename "$folder")"
    # Check the size of the file on the remote
    remote_size=$(rclone size --json "$mount/$(basename "$zip_file")" | jq .bytes)
    # Check the size of the local file
    local_size=$(stat -c%s "$zip_file")
    # If the sizes are different, upload the file
    if [ "$remote_size" -ne "$local_size" ]; then
      echo "Starting upload of $zip_file to the mount"
      rclone copy "$zip_file" "$mount"
      echo "Uploaded $zip_file to the mount"
    else
      echo "There is no changes in file size for $zip_file, not uploading"
    fi
  fi
done

echo "Powering back on all previously running docker containers..."

# Power back on all previously running docker containers
if [ ! -z "$running_containers" ]; then
  for container in $running_containers; do
    if [[ ! " ${exclude_list[@]} " =~ " $(docker inspect --format='{{.Name}}' "$container" | tr -d '/') " ]]; then
      docker start "$container"
      echo "Powered on container: $container"
    fi
  done
fi
