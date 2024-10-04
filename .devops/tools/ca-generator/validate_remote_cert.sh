#!/usr/bin/env bash
# [[ ${DOCLI_DEBUG:-false} == true ]]       && set -exo pipefail || set -eo pipefail
# [[ ${DOCLI_UNSET_VARS:-false} == true ]]  && set -u

# Configuration
check_url="${DOCLI_PRIVATE_CA_URL:-localhost}"
LOCAL_CA_CERT="$DOCLI/CA/intermediateCA/certs/ca-chain-cert.pem"

# Download the site certificate
echo | openssl s_client -connect $check_url 2>/dev/null | openssl x509 -out /tmp/site.crt

# Validate the downloaded certificate against the local CA certificate
openssl verify -CAfile $LOCAL_CA_CERT /tmp/site.crt

# Print validation status
if [[ $? -eq 0 ]]; then
  echo "Certificate is valid."
else
  echo "Certificate is not valid."
fi

# Cleanup
rm /tmp/site.crt
