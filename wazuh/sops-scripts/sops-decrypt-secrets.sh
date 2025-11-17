#!/bin/bash
set -e

# Base directory of your secrets
SECRET_DIR="../"

# Find all encrypted files with sops (.enc.yaml)
FILES=$(find "$SECRET_DIR" -type f -name "*.enc.yaml" \
  \( -path "*/secrets/*" -o \
     -path "*/cron_job/secrets/*" -o \
     -path "*/wazuh_managers/wazuh_conf/syslog-ng-secrets/*" \))

# Decrypt each file
for f in $FILES; do
    # Generate a new name with the suffix ".decrypted.yaml"
    DECRYPTED="${f/.enc.yaml/.decrypted.yaml}"
    echo "Decrypting $f -> $DECRYPTED"
    sops -d "$f" > "$DECRYPTED"
done

echo "✅ All secrets were successfully decrypted (files with the .decrypted.yaml suffix)."
