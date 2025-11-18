#!/bin/bash
set -e

SECRET_DIR="../"
echo "🔍 Verifying secret synchronization..."

# Buscar todos los archivos cifrados (.enc y .enc.yaml)
ENCRYPTED_FILES=$(find "$SECRET_DIR" -type f \( -name "*.enc.yaml" -o -name "*.enc" \))

ERRORS=0

for enc in $ENCRYPTED_FILES; do
    # Detectar archivo original y tipo de comparación
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
        # YAML -> normalizar con yq
        if diff <(sops -d "$enc" 2>/dev/null | yq eval -o=json) <(yq eval -o=json "$original") >/dev/null; then
            echo "✅ OK"
        else
            echo "❌ MISMATCH"
            ERRORS=$((ERRORS+1))
        fi
    else
        # Archivos .conf -> comparar crudo
        if diff <(sops -d "$enc" 2>/dev/null) "$original" >/dev/null; then
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
