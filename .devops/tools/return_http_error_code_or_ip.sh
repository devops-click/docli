#### FOR ANY HTTP ERROR CODE
# Returns the IP Address in case of success and the HTTP error code in case of failure (40x and 50x)
get_http_status() {
  local curl_url=$1
  # Send the request and capture the HTTP status code along with the response
  response=$(curl -s -w "\n%{http_code}" "$curl_url")
  status_code=$(echo "$response" | tail -n1)
  content=$(echo "$response" | sed '$d')

  # Handle based on the HTTP status code
  if [[ $status_code == 200 ]]; then
    echo "$content"
  elif [[ ${status_code:0:2} == 40 ]]; then
    echo "40x"
  elif [[ ${status_code:0:2} == 50 ]]; then
    echo "50x"
  else
    echo "$status_code"
  fi
}

private_ip=$(get_http_status "http://169.254.169.254/latest/meta-data/local-ipv4")
public_ip=$(get_http_status "http://169.254.169.254/latest/meta-data/public-ipv4")

echo "Consul Private IP: $private_ip"
echo "Consul Public IP: $public_ip"

#### SPECIFYING THE ERROR CODE (ANY)
# Returns the IP Address in case of success and the HTTP error code in case of failure (ANY)
get_http_status() {
  local curl_url=$1
  # Send the request and capture the HTTP status code
  status_code=$(curl -o /dev/null -s -w "%{http_code}\n" "$curl_url")
  # Handle based on the HTTP status code
  if [[ $status_code == 200 ]]; then
    # In case of a 200 status, actually retrieve the content
    ip_address=$(curl -s "$curl_url")
    echo "$ip_address"
  else
    # For non-200 status codes, return the code itself
    echo "$status_code"
  fi
}
private_ip=$(get_http_status http://169.254.169.254/latest/meta-data/local-ipv4)
public_ip=$(get_http_status http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Consul Private IP: $private_ip"
echo "Consul Public IP: $public_ip"