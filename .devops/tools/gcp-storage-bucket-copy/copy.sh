#!/usr/bin/env bash
[[ ${DOCLI_DEBUG:-false} == true ]]       && set -exo pipefail || set -eo pipefail
[[ ${DOCLI_UNSET_VARS:-false} == true ]]  && set -u
############################################################################### #dltbr
#              https://DevOps.click - DevOps taken seriously                  # #dltbr
###############################################################################
# bash --version

#:: ## Google Cloud - Storage Bucket Copy Script
#:: Use this script to copy files based in a list to a brand new bucket. Mostly for testing purposes or bucket duplication.
#:: BEWARE: creation and modified date cannot be retained, If you need those attributes, you should choose another method.
#:: #### Usage
#:: `./copy --source-bucket <bucket> --destination-bucket <bucket> [--destination-region <region>] [--credentials-file <file>] [--source-folders <folder1,folder2,...>]`
#:: ```
#:: --source-bucket           | REQUIRED: Source bucket name without gs://."
#:: --destination-bucket      | REQUIRED: Destination bucket name without gs://."
#:: --destination-region      | OPTIONAL: Destination bucket region. Default: EUROPE-WEST3."
#:: --credentials-file        | OPTIONAL: Location of the Google Cloud credential JSON file."
#:: --source-folders          | OPTIONAL: Comma-separated list of source folders to copy."
#:: ```
#:: #### Example
#:: `./copy.sh --source-bucket devops-source-files --destination-bucket devops-destination-files --destination-region EUROPE-WEST3 --credentials-file ~/gcloud_cred.json --source-folders folder1/subfolder1,folder2/subfolder2`

help_script() {
  echo "Usage: $0 --source-bucket <bucket> --destination-bucket <bucket> [--destination-region <region>] [--credentials-file <file>] [--source-folders <folder1,folder2,...>]"
  echo "--------------------------------------------------------------"
  echo "--source-bucket           | REQUIRED: Source bucket name without gs://."
  echo "--destination-bucket      | REQUIRED: Destination bucket name without gs://."
  echo "--destination-region      | OPTIONAL: Destination bucket region. Default: EUROPE-WEST3."
  echo "--credentials-file        | OPTIONAL: Location of the Google Cloud credential JSON file."
  echo "--source-folders          | OPTIONAL: Comma-separated list of source folders to copy."
  echo "--------------------------------------------------------------"
  echo "Example: $0 --source-bucket devops-source-files --destination-bucket devops-destination-files --destination-region EUROPE-WEST3 --credentials-file ~/gcloud_cred.json --source-folders folder1/subfolder1,folder2/subfolder2"
}

# Default values
DESTINATION_REGION="EUROPE-WEST3"
GCS_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS:-./gcloud-credentials.json}"
SOURCE_FOLDERS=()

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --source-bucket) SOURCE_BUCKET="$2"; shift ;;
    --destination-bucket) DESTINATION_BUCKET="$2"; shift ;;
    --destination-region) DESTINATION_REGION="${2:-$DESTINATION_REGION}"; shift ;;
    --credentials-file) GCS_CREDENTIALS="$2"; shift ;;
    --source-folders) IFS=',' read -r -a SOURCE_FOLDERS <<< "$2"; shift ;;
    *) echo "Unknown parameter: $1"; help_script; exit 1 ;;
  esac
  shift
done

# Check if required variables are set
if [ -z "${SOURCE_BUCKET:-}" ] || [ -z "${DESTINATION_BUCKET:-}" ]; then
  help_script
  exit 1
fi

if [ -z "${CLOUDSDK_CORE_PROJECT:-}" ]; then
  echo "ERROR: Please setup your Project ID: export CLOUDSDK_CORE_PROJECT=project-XXXXXX"
  exit 1
fi

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
gcloud_authenticate

# If additional arguments are provided, use them as SOURCE_FOLDERS
# Otherwise, set SOURCE_FOLDERS to an empty array to copy the entire bucket
if [ ! -z ${SOURCE_FOLDERS:-} ]; then
  echo "* folders passed... *"
else
  echo "* folders NOT passed... *"
  SOURCE_FOLDERS=()
fi

# Check if the bucket already exists
if gsutil ls -b gs://$DESTINATION_BUCKET &>/dev/null; then
  echo "Bucket 'gs://$DESTINATION_BUCKET' already exists."
else
  # Create the bucket
  gsutil mb -l $DESTINATION_REGION gs://$DESTINATION_BUCKET

  # Check if the bucket creation was successful
  if [ $? -eq 0 ]; then
    echo "Bucket 'gs://$DESTINATION_BUCKET' created successfully in region '$DESTINATION_REGION'."
  else
    echo "Failed to create bucket 'gs://$DESTINATION_BUCKET'."
  fi
fi

# Loop through the source folders and copy contents to the destination bucket
if [ ${#SOURCE_FOLDERS[@]} -eq 0 ]; then
  echo "Copying entire bucket 'gs://$SOURCE_BUCKET' to 'gs://$DESTINATION_BUCKET'."
  # Use gsutil -m to perform parallel copies for efficiency
  gsutil -m cp -r "gs://$SOURCE_BUCKET/" "gs://$DESTINATION_BUCKET/"                                # default option
  # gsutil -m cp -r -P "gs://$SOURCE_BUCKET/$SRC_FOLDER" "gs://$DESTINATION_BUCKET/$SRC_FOLDER"       # -P option to preserve some metadata
  # gcloud storage -m cp -r "gs://$SOURCE_BUCKET/$SRC_FOLDER" "gs://$DESTINATION_BUCKET/$SRC_FOLDER"  # Using gcloud storage option
else
  for SRC_FOLDER in "${SOURCE_FOLDERS[@]}"; do
    echo "Copying 'gs://$SOURCE_BUCKET/$SRC_FOLDER' to 'gs://$DESTINATION_BUCKET/$SRC_FOLDER'."
    gsutil -m cp -r "gs://$SOURCE_BUCKET/$SRC_FOLDER" "gs://$DESTINATION_BUCKET/$SRC_FOLDER"
  done
fi

echo "**** end of copy ****"

# DELETE BUCKET FORCE IF NEEDED
# gsutil -m rm -r -f gs://devops-destination-files