#!/bin/bash
set -e

# Base directory of your secrets
SECRET_DIR="../"

# Find all encrypted files with sops (.enc or .enc.yaml)
FILES=$(find "$SECRET_DIR" -type f \( -name "*.enc.yaml" -o -name "*.enc" \))

# Decrypt each file
for f in $FILES; do
    if [[ "$f" == *.enc.yaml ]]; then
        DECRYPTED="${f/.enc.yaml/.decrypted.yaml}"
    elif [[ "$f" == *.enc ]]; then
        DECRYPTED="${f/.enc/.decrypted.conf}"
    else
        echo "Skipping unknown file $f"
        continue
    fi

    echo "Decrypting $f -> $DECRYPTED"
    sops -d "$f" > "$DECRYPTED"
done

echo "✅ All secrets were successfully decrypted."
