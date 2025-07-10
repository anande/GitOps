#!/bin/bash

# Directory for the repository
REPO_DIR="/var/www/yumrepo"

# Upstream repositories to sync (example: AlmaLinux BaseOS and AppStream)
REPOS="baseos appstream epel"

# Ensure the repository directory exists
mkdir -p "$REPO_DIR"

# Sync each repository
for repo in $REPOS; do
    reposync --repo="$repo" --download-metadata --download-path="$REPO_DIR/$repo" --newest-only
    createrepo_c "$REPO_DIR/$repo"
done

# Ensure permissions are correct for Nginx
chown -R nginx:nginx "$REPO_DIR"
chmod -R 755 "$REPO_DIR"