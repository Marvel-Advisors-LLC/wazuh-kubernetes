#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <KMS_ARN>"
    exit 1
fi

KMS_ARN="$1"
SECRET_DIR="."

# Find all original (unencrypted) files
FILES=$(find "$SECRET_DIR" -type f \( \
    \( -name "*.yaml" -path "*/secrets/*" -o \
       -path "*/cron_job/secrets/*" -o \
       -path "*/wazuh_managers/wazuh_conf/syslog-ng-secrets/*" \) -o \
    -name "worker.conf" -o -name "master.conf" \) ! -name "*.enc.yaml"
)

for f in $FILES; do
    case "$f" in
        *.conf) ENC="${f}.enc" ;;       # only .enc for .conf files
        *.yaml) ENC="${f%.yaml}.enc.yaml" ;;  # .enc.yaml for regular YAML files
        *) echo "Skipping unknown file $f"; continue ;;
    esac

    echo "Encrypting $f -> $ENC"
    sops --encrypt --kms "$KMS_ARN" "$f" > "$ENC"
done

echo "✅ All secrets were encrypted correctly. Encrypted files have the .enc.yaml suffix."



