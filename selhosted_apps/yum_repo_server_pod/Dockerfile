# Use AlmaLinux 8 as the base image
FROM almalinux:8

# Install required packages
RUN dnf install -y epel-release && \
    dnf install -y nginx createrepo_c dnf-utils && \
    dnf clean all

# Create directory for the YUM repository
RUN mkdir -p /var/www/yumrepo

# Copy script to download packages and create repo
COPY sync-repo.sh /usr/local/bin/sync-repo.sh
RUN chmod +x /usr/local/bin/sync-repo.sh

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 for HTTP
EXPOSE 80

# Set ownership and permissions for the repo directory
RUN chown -R nginx:nginx /var/www/yumrepo && \
    chmod -R 755 /var/www/yumrepo

# Command to run Nginx in the foreground and sync repo on startup
CMD ["/bin/sh", "-c", "/usr/local/bin/sync-repo.sh && nginx -g 'daemon off;'"]