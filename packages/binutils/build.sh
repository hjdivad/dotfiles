#!/bin/bash

# Get the directory of this script file
script_dir=$(dirname "${BASH_SOURCE[0]}")

# Define the directories to iterate over
dirs=()
while IFS=  read -r -d $'\0'; do
    dirs+=("$REPLY")
done < <(find "$script_dir/crates/project" -type d -depth 1 -print0)

# Build & Install the global binutils
dir="$script_dir/crates/global"
(cd "$dir" && cargo install --path . --quiet > /dev/null 2>&1)
# If the build command fails, exit with a non-zero status
if [ $? -ne 0 ]; then
  printf "Error building: %s\n\n" "$dir"
  (cd "$dir" && cargo build)
  exit 1
fi

# Build project-specific utils
for dir in "${dirs[@]}"; do
  # For each directory, check if it exists and is a directory
  if [ -d "$dir" ]; then
    # If it is, run the build command
    (cd "$dir" && cargo build --quiet > /dev/null 2>&1)
    # If the build command fails, exit with a non-zero status
    if [ $? -ne 0 ]; then
      printf "Error building: %s\n\n" "$dir"
      (cd "$dir" && cargo build)
      exit 1
    fi
  fi
done

# If all builds succeed, exit with a zero status
exit 0
