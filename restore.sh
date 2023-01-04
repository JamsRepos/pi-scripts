#!/bin/bash

# Set the backup and app data directories
backup_dir="/opt/backups"
app_data_dir="/opt/appdata"

# Set the mount point
mount="idrive:backups"

# Read all file names in the mount point
files=("all containers")
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

if [[ "$file" == "all containers" ]]; then
  # Ask if the restore should be local or remote
  read -p "Local or remote restore for all files? [l/r] " restore_type

  # Loop through all of the files and perform the restore operation on each of them
  for f in "${files[@]}"; do
    # Skip the "all containers" option
    if [[ "$f" == "all containers" ]]; then
      continue
    fi

    # Get the file name without the extension
    container_name="${f%.*.*}"

    if [[ "$restore_type" == "l" ]]; then
      if [[ -f "$backup_dir/$f" ]]; then
        echo "Extracting $f in $app_data_dir..."
        tar -xvf "$backup_dir/$f" -C "$app_data_dir" &>/dev/null
        cd "$app_data_dir/$container_name"
        echo "Finally, restoring $container_name!"
        docker-compose up -d
      else
        read -p "File does not exist. Select 'r' for remote restore or 'c' to cancel: " choice
        if [[ "$choice" == "r" ]]; then
          restore_type="r"
        else
          exit
        fi
      fi
    fi

    if [[ "$restore_type" == "r" ]]; then
      echo "Copying $f from $mount to $backup_dir..."
      rclone copy "$mount/$f" "$backup_dir"
      echo "Extracting $f in $app_data_dir..."
      tar -xvf "$backup_dir/$f" -C "$app_data_dir" &>/dev/null
      cd "$app_data_dir/$container_name"
      echo "Finally, restoring $container_name!"
      docker-compose up -d
    fi
  done
else
  # Get the file name without the extension
  container_name="${file%.*.*}"

  # Ask if the restore should be local or remote
  read -p "Local or remote restore? [l/r] " restore_type

  if [[ "$restore_type" == "l" ]]; then
    if [[ -f "$backup_dir/$file" ]]; then
      echo "Extracting $file in $app_data_dir..."
      tar -xvf "$backup_dir/$file" -C "$app_data_dir" &>/dev/null
      cd "$app_data_dir/$container_name"
      echo "Finally, restoring $container_name!"
      docker-compose up -d
    else
      read -p "File does not exist. Select 'r' for remote restore or 'c' to cancel: " choice
      if [[ "$choice" == "r" ]]; then
        restore_type="r"
      else
        exit
      fi
    fi
  fi

  if [[ "$restore_type" == "r" ]]; then
    echo "Copying $file from $mount to $backup_dir..."
    rclone copy "$mount/$file" "$backup_dir"
    echo "Extracting $file in $app_data_dir..."
    tar -xvf "$backup_dir/$file" -C "$app_data_dir" &>/dev/null
    cd "$app_data_dir/$container_name"
    echo "Finally, restoring $container_name!"
    docker-compose up -d
  fi
fi
