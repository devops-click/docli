#!/bin/bash

# Configuration
WEBSITE="consul-test.use1.ent.devops.click:8501"
LOCAL_CA_CERT="$DOCLI/CA/intermediateCA/certs/ca-chain-cert.pem"

# Download the site certificate
echo | openssl s_client -connect $WEBSITE 2>/dev/null | openssl x509 -out /tmp/site.crt

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

