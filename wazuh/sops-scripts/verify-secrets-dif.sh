#!/bin/bash
set -e

# Carpeta base donde están los secrets
SECRET_DIR="../"

echo "🔍 Verifying secret synchronization..."

# Buscar todos los archivos cifrados
ENCRYPTED_FILES=$(find "$SECRET_DIR" -type f -name "*.enc.yaml")

ERRORS=0

for enc in $ENCRYPTED_FILES; do
    # Obtener el path del archivo original sin la extensión .enc.yaml
    original="${enc/.enc.yaml/.yaml}"

    echo -n "Checking $(basename "$enc") ... "

    if [[ ! -f "$original" ]]; then
        echo "❌ Original file NOT FOUND: $original"
        ERRORS=$((ERRORS+1))
        continue
    fi

    # Comparar contenido desencriptado vs original normalizado por yq
    DECRYPTED_CONTENT=$(sops -d "$enc" 2>/dev/null | yq eval '.' -o=yaml)
    ORIGINAL_CONTENT=$(yq eval '.' -o=yaml "$original")

    if diff <(sops -d "$enc" | yq eval -o=json) <(yq eval -o=json "$original") >/dev/null; then
        echo "✅ OK"
    else
        echo "❌ MISMATCH"
        ERRORS=$((ERRORS+1))
    fi
done

if [[ $ERRORS -gt 0 ]]; then
    echo "❌ Verification FAILED: $ERRORS inconsistencies found."
    exit 1
else
    echo "✅ All secrets are perfectly synchronized."
    exit 0
fi
