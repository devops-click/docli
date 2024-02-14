#!/usr/bin/env bash
set -euo pipefail
# bash --version
###############################################################################
#                       docli Google Cloud - Cleanup Bucket
#                      auxiliary script to lifecycle policy
###############################################################################
# v1.0
# https://devops.click/category/gcp/

#:: ## Google Cloud - Storage Cleanup Script
#:: This script recursively clean files from GCS Bucket with the following configuration/functionalities:
#:: - Check if your Google Cloud Connectivity is ok, otherwise, connect it
#:: - Automatically import your gcloud credentials file. You can have it in $GOOGLE_APPLICATION_CREDENTIALS environment variable, or use local folder file with this name: gcloud-credentials.json
#:: - Consider $REPROCESSING_WINDOW variable in minutes, to not repeat the cleanup for already visited buckets
#:: - Consider each file Storage Class to ensure it does not delete before retention period in case of NEARLINE, COLDLINE and ARCHIVE. (Avoiding additional charges)
#:: - Recursively goes into each dir automatically to apply the cleanup (if needed, test it before applying to a critical backup bucket)
#:: - Always keep the newest X not empty files (independent of it’s date, defaults to 7 if not specified), to avoid deletition of "good" backups
#:: - Can be runned multiple times
#:: #### Usage
#:: `./cleanup <bucket-name> <number-of-files-to-keep-in-dir> <reprocessing_window> <gcs_credentials_file_location>`
#:: ```
#:: bucket-name                     | REQUIRED -> Name of the bucket without gs://. ex: devops-backups
#:: number-of-files-to-keep-in-dir  | OPTIONAL -> Number of files to keep in each dir. Default: 7
#:: reprocessing_window             | OPTIONAL -> Number of minutes to enable reprocesses a already visited folder. Default: 360 (6h)
#:: gcs_credentials_file_location   | OPTIONAL -> Location of the google cloud credential JSON file. Can be set by GOOGLE_APPLICATION_CREDENTIALS env variable or by putting script into local folder with the filename gcloud-credentials.json
#:: ```
#:: #### Example
#:: `./cleanup devops-backup 14 720 $HOME/gcloud_cred.json`

help_script() {
  echo "Usage: $0 <bucket-name> <number-of-files-to-keep-in-dir> <reprocessing_window> <gcs_credentials_file_location>"
  echo "--------------------------------------------------------------"
  echo "bucket-name                     | REQUIRED -> Name of the bucket without gs://. ex: devops-backups"
  echo "number-of-files-to-keep-in-dir  | OPTIONAL -> Number of files to keep in each dir. Default: 7"
  echo "reprocessing_window             | OPTIONAL -> Number of minutes to enable reprocesses a already visited folder. Default: 360 (6h)"
  echo "gcs_credentials_file_location   | OPTIONAL -> Location of the google cloud credential JSON file. Can be set by GOOGLE_APPLICATION_CREDENTIALS env variable or by putting script into local folder with the filename gcloud-credentials.json"
  echo "--------------------------------------------------------------"
  echo "Example:            ./cleanup devops-backup 14 720 ~/gcloud_cred.json"
  echo "or using defaults:  ./cleanup devops-backup"
}

# Check if $1 is not passed
if [ "${1:-}" = "" ]; then
  help_script
  exit 1
fi

# Set your GCS bucket name
BUCKET_NAME="$1"
LAST_X_ITEMS=${2:-7} # Set LAST_X_ITEMS to the second argument passed to the script or default to 7 if not provided
REPROCESSING_WINDOW=${3:-360} # 6h # In minutes, tells the script when to clean cache for which folders it already process or not
GCS_CREDENTIALS="${4:-${GOOGLE_APPLICATION_CREDENTIALS:-./gcloud-credentials.json}}"

# Storage class minimum durations in days
declare -A MIN_DURATION
MIN_DURATION[STANDARD]=0
MIN_DURATION[NEARLINE]=30
MIN_DURATION[COLDLINE]=90
MIN_DURATION[ARCHIVE]=365

# Authenticate and check access to GCP API
gcloud_authenticate() {
  # Check if any account is authenticated
  if gcloud auth list 2>&1 | grep -q 'No credentialed accounts.'; then
    echo "No authenticated accounts found. Authenticating with service account..."
    gcloud auth activate-service-account --key-file="$GCS_CREDENTIALS"
  else
    echo "An account is already authenticated."
  fi

  # Check access to GCP API
  if gcloud projects list --limit=1 2>&1 | grep -q 'Listed 0 items.'; then
    echo "Failed to list projects, re-authenticating..."
    # Authenticate using the service account
    gcloud auth activate-service-account --key-file="$GCS_CREDENTIALS"
  else
    echo "Successfully accessed GCP API."
  fi
}

# Function to remove /tmp/processed_files that are older than X hours
cleanup_old_processed_files() {
  echo "Cleaning up old processed files..."
  find /tmp -name 'processed_files_*' -mmin +$REPROCESSING_WINDOW -exec rm {} \;
}

# Function to get storage class and creation time of a file
get_file_info() {
  local file_path=$1
  gsutil ls -L "$file_path" | grep -E "Storage class:|Creation time:" || echo "Error: Unable to get file info for $file_path"
}

# Function to check if a file can be safely deleted based on its storage class and age
can_delete_file() {
  local file_path=$1
  local file_info=$(get_file_info "$file_path")

  if [[ "$file_info" == *"Error:"* ]]; then
    echo "$file_info"
    return 1
  fi

  local storage_class=$(echo "$file_info" | grep "Storage class:" | awk '{print $3}')
  local creation_time_str=$(echo "$file_info" | grep "Creation time:" | awk '{print $3, $4, $5, $6, $7}')
  local creation_time

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    creation_time=$(date -d "$creation_time_str" '+%s')
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    creation_time=$(date -j -f "%a, %d %b %Y %H:%M:%S" "$creation_time_str" "+%s")
  else
    echo "unsupported OS for date parsing"
    return 1
  fi

  if [[ -z "$creation_time" ]]; then
    echo "Error: Failed to parse creation time for $file_path"
    return 1
  fi

  local current_date_sec=$(date '+%s')
  local age_days=$(( (current_date_sec - creation_time) / 86400 ))

  local min_duration=${MIN_DURATION[$storage_class]}

  # [[ $age_days -ge $min_duration ]]
  if [[ $age_days -lt $min_duration ]]; then
    echo "retention policy not met: $storage_class < ${min_duration} days"
    return 1
  fi
}

# Function to delete old files
delete_old_files() {
  local dir_path=$1
  local flag_file="/tmp/processed_files_${dir_path//\//_}"

  # Check if the files in the directory have already been processed
  if [ -f "$flag_file" ]; then
    echo "Already processed files in dir_path: $dir_path"
    return
  fi
  touch "$flag_file"
  echo "Processing dir_path for file deletion: $dir_path"

  local files=$(gsutil ls -l "gs://${BUCKET_NAME}/${dir_path}" | sort -k2n | awk '{if ($1 > 128) print $3}')
  local file_count=$(echo "$files" | grep -c '^')

  if [ "$file_count" -gt $LAST_X_ITEMS ]; then
    echo "$files" | head -n $((file_count - LAST_X_ITEMS)) | while read -r file; do
      if [[ "$file" == gs://* ]] && can_delete_file "$file"; then
        echo "Deleting: $file"
        gsutil rm "$file"
      else
        echo "Skipping deletion (retention policy not met): $file"
      fi
    done
  fi
}

# Declare associative array to track processed directories
declare -A processed_dirs

# Function to recursively process each path
process_paths() {
  local current_path="${1%/}" # Remove trailing slash if any
  echo "Current path: $current_path"

  # Use a specific key for the root directory
  local dir_key=${current_path:-"ROOT"}

  # Initialize the directory key in the associative array if not already set
  if [ -z "${processed_dirs[$dir_key]+_}" ]; then
    processed_dirs[$dir_key]=0
  fi

  # Check if the directory has already been processed
  if [[ "${processed_dirs[$dir_key]}" -eq 1 ]]; then
    echo "Skipping already processed directory: $current_path"
    return
  fi
  processed_dirs[$dir_key]=1
  echo "Processing directory: $current_path"

  # List directories and files under the current path
  local items=$(gsutil ls "gs://${BUCKET_NAME}/${current_path}")

  for item in $items; do
    if [[ "$item" == */ ]]; then
      # It's a directory, process it if not already done
      local new_path="${item#"gs://${BUCKET_NAME}/"}"
      new_path="${new_path%/}" # Remove trailing slash
      process_paths "$new_path"
    else
      # It's a file, process the directory for file deletion
      local file_dir="$(dirname "${item#"gs://${BUCKET_NAME}/"}")/"
      delete_old_files "$file_dir"
    fi
  done
}

# Main processing logic
gcloud_authenticate
cleanup_old_processed_files
echo "Starting processing"
process_paths ""
echo "Finished processing"
