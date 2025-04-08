#!/bin/bash

# Create a temporary directory for Kustomize
tmpdir=$(mktemp -d)

# case $1 in 
#     --env) ENV="$2";
# esac

# Copy rendered manifests to the temporary directory
# cp -r rendered-dev/webapp1/templates/* "$tmpdir"
cp -r rendered-$ENV/webapp1/templates/* "$tmpdir"

# Create a basic kustomization.yaml if needed
cat > "$tmpdir/kustomization.yaml" <<EOF
resources:
  - app.yaml
  - svc.yaml
  - cm.yaml

patches:
  - path: patch.yaml
EOF

# Apply Kustomize to modify the manifests
kustomize build "$tmpdir" > modified-manifests-dev.yaml

# Remove the temporary directory
rm -rf "$tmpdir"

# Output the modified manifests
cat modified-manifests-dev.yaml
