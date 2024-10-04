#!/usr/bin/env bash
[[ ${DOCLI_DEBUG:-false} == true ]]       && set -exo pipefail || set -eo pipefail
[[ ${DOCLI_UNSET_VARS:-false} == true ]]  && set -u

# Define the target and port
TARGET="${1:-google.com}"
PORT=${2:-443}
MS=${3:-0.1}

# Function to check if the target is an IP address
is_ip() {
  local ip="$1"
  [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# Get all IP addresses associated with the TARGET
IP_LIST=$(dig +short "$TARGET")

# Determine if the TARGET is an IP address or a domain name
if is_ip "$TARGET"; then
  IP="$TARGET"
  TYPE="ip"
else
  # Resolve the domain name to get the first IP address
  IP=$(dig +short "$TARGET" | head -n 1)

  # Convert the IP addresses into a bash array
  IFS=$'\n' read -r -d '' -a IP_ARRAY <<< "$IP_LIST"

  # Print all IP addresses
  echo -e "\n*************************************************"
  echo "All IP addresses for $TARGET:"
  for IP in "${IP_ARRAY[@]}"; do
    echo "$IP"
  done
  echo -e "*************************************************\n"
  TYPE="dns"
fi

[[ $TYPE == "dns" ]] && echo -e "* $TARGET:$PORT (IP:$IP) *" || echo -e "* $TARGET:$PORT *"
echo

# Loop to check response time every 0.1 seconds
while true; do
  # Measure the time taken for the nc connection
  START_TIME=$(date +%s%3N)
  nc -z $IP $PORT >/dev/null 2>&1
  END_TIME=$(date +%s%3N)

  # Calculate response time in milliseconds
  RESPONSE_TIME=$((END_TIME - START_TIME))

  # Check if nc was successful
  if [ $? -eq 0 ]; then
    echo "$IP: ${RESPONSE_TIME}ms"
    # echo "Port $PORT is open. Response time: ${RESPONSE_TIME}ms."
  else
    echo "Port $PORT is closed or unreachable."
  fi

  sleep $MS
done
