#!/usr/bin/env bash
#
# sync-crds.sh - Sync CRDs from teranode-operator submodule
#
# This script updates the operator submodule to a specific version tag and copies the CRDs.
# Usage: ./sync-crds.sh [version]
#   Example: ./sync-crds.sh v0.1.3
#   If no version specified, uses the appVersion from Chart.yaml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPERATOR_DIR="${SCRIPT_DIR}/operator"
CRDS_SOURCE="${OPERATOR_DIR}/deploy/crds.yaml"
CRDS_DEST="${SCRIPT_DIR}/crds"

# Get version from argument or Chart.yaml
if [ -n "${1:-}" ]; then
    VERSION="$1"
else
    VERSION="v$(grep '^appVersion:' Chart.yaml | awk '{print $2}' | tr -d '"')"
fi

echo "🔄 Syncing CRDs from teranode-operator ${VERSION}..."

# Check if operator submodule exists
if [ ! -d "${OPERATOR_DIR}" ]; then
    echo "❌ Error: Operator submodule not found at ${OPERATOR_DIR}"
    echo "   Run: git submodule update --init --recursive"
    exit 1
fi

# Update submodule and checkout specific version
echo "📥 Updating operator submodule to ${VERSION}..."
cd "${OPERATOR_DIR}"
git fetch --tags
if ! git checkout "${VERSION}" 2>/dev/null; then
    echo "❌ Error: Version ${VERSION} not found in operator repository"
    echo "   Available tags:"
    git tag -l | tail -10
    exit 1
fi
cd "${SCRIPT_DIR}"

# Check if CRDs source exists
if [ ! -f "${CRDS_SOURCE}" ]; then
    echo "❌ Error: CRDs source file not found at ${CRDS_SOURCE}"
    exit 1
fi

# Create crds directory if it doesn't exist
mkdir -p "${CRDS_DEST}"

# Copy the CRDs file
echo "📋 Copying ${CRDS_SOURCE} to ${CRDS_DEST}/"
cp "${CRDS_SOURCE}" "${CRDS_DEST}/crds.yaml"

echo "✅ CRDs synced successfully from operator ${VERSION}!"
echo ""
echo "📊 CRD Stats:"
grep -c "^kind: CustomResourceDefinition" "${CRDS_DEST}/crds.yaml" | xargs echo "   Total CRDs:"

# Show which CRDs were synced
echo ""
echo "📝 Synced CRDs:"
grep "name: " "${CRDS_DEST}/crds.yaml" | grep "\.teranode\.bsvblockchain\.org" | sed 's/.*name: /   - /'

echo ""
echo "ℹ️  Don't forget to commit the updated CRDs and submodule:"
echo "   git add crds/ operator"
echo "   git commit -m 'Update CRDs from operator ${VERSION}'"
