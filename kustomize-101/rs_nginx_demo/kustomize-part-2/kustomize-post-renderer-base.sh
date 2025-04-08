#!/bin/bash

# Create a temporary directory for Kustomize
tmpdir=$(mktemp -d)

# Copy rendered manifests to the temporary directory
cp -r rendered-base/webapp1/templates/* "$tmpdir"

# Create a basic kustomization.yaml if needed
cat > "$tmpdir/kustomization.yaml" <<EOF
resources:
  - app.yaml
  - svc.yaml
  - cm.yaml
EOF

# Apply Kustomize to modify the manifests
kustomize build "$tmpdir" > modified-manifests-base.yaml

# Remove the temporary directory
rm -rf "$tmpdir"

# Output the modified manifests
cat modified-manifests-base.yaml
