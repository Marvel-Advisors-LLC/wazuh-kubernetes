#!/bin/bash
set -e

# Verify that a KMS ARN was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <KMS_ARN>"
    exit 1
fi

KMS_ARN="$1"

# Base directory of your secrets
SECRET_DIR="../"

# Find all YAML files that are secrets (adjust the paths according to your repo)
FILES=$(find "$SECRET_DIR" -type f -name "*.yaml" \
  \( -path "*/secrets/*" -o \
     -path "*/cron_job/secrets/*" -o \
     -path "*/wazuh_managers/wazuh_conf/syslog-ng-secrets/*" \))

# Encrypt each file
for f in $FILES; do

    # Replace .yaml with .enc.yaml (clean, correct)
    ENC="${f%.yaml}.enc.yaml"

    echo "Encrypting $f -> $ENC"
    sops --encrypt --kms "$KMS_ARN" "$f" > "$ENC"
done

echo "✅ All secrets were encrypted correctly. Encrypted files have the suffix .enc.yaml."
