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
    -name "worker.conf" -o \
    -name "master.conf" -o \
    -name "*.crt" -o \
    -name "*.key" \) ! -name "*.enc.yaml" ! -name "*.enc"
)

IFS=$'\n'

for f in $FILES; do
    case "$f" in
        *.conf|*.crt|*.key)
            ENC="${f}.enc"
            ;;
        *.yaml)
            ENC="${f%.yaml}.enc.yaml"
            ;;
        *)
            echo "Skipping unknown file $f"
            continue
            ;;
    esac

    echo "Encrypting $f -> $ENC"
    sops --encrypt --kms "$KMS_ARN" "$f" > "$ENC"
done

echo "✅ All secrets were encrypted correctly."



