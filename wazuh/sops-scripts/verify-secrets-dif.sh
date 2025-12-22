#!/bin/bash
set -e

SECRET_DIR="../"
echo "🔍 Verifying secret synchronization..."

# -----------------------------
# Pre-flight checks
# -----------------------------

# Check required commands
command -v sops >/dev/null 2>&1 || {
  echo "❌ sops is not installed or not in PATH"
  exit 1
}

command -v aws >/dev/null 2>&1 || {
  echo "❌ aws CLI is not installed or not in PATH"
  exit 1
}

command -v yq >/dev/null 2>&1 || {
  echo "❌ yq is not installed or not in PATH"
  exit 1
}

# Check AWS credentials (required for SOPS + KMS)
if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "❌ AWS credentials not available."
  echo "   Please export AWS_PROFILE or AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY"
  echo "   before committing."
  exit 1
fi

# -----------------------------
# Main logic
# -----------------------------

# Look for all encrypted files (.enc and .enc.yaml)
ENCRYPTED_FILES=$(find "$SECRET_DIR" -type f \( -name "*.enc.yaml" -o -name "*.enc" \))

ERRORS=0

for enc in $ENCRYPTED_FILES; do
    # Detect original file and comparison type
    if [[ "$enc" == *.enc.yaml ]]; then
        original="${enc/.enc.yaml/.yaml}"
        USE_YQ=true
    elif [[ "$enc" == *.enc ]]; then
        original="${enc/.enc/}"
        USE_YQ=false
    else
        echo "Skipping unknown file $enc"
        continue
    fi

    echo -n "Checking $(basename "$enc") ... "

    if [[ ! -f "$original" ]]; then
        echo "❌ Original file NOT FOUND: $original"
        ERRORS=$((ERRORS+1))
        continue
    fi

    if [[ "$USE_YQ" == true ]]; then
        # YAML -> normalize with yq
        if diff <(sops -d "$enc" | yq eval -o=json) <(yq eval -o=json "$original") >/dev/null; then
            echo "✅ OK"
        else
            echo "❌ MISMATCH"
            ERRORS=$((ERRORS+1))
        fi
    else
        # .conf files -> compare raw
        if diff <(sops -d "$enc") "$original" >/dev/null; then
            echo "✅ OK"
        else
            echo "❌ MISMATCH"
            ERRORS=$((ERRORS+1))
        fi
    fi
done

if [[ $ERRORS -gt 0 ]]; then
    echo "❌ Verification FAILED: $ERRORS inconsistencies found."
    exit 1
else
    echo "✅ All secrets are perfectly synchronized."
    exit 0
fi
