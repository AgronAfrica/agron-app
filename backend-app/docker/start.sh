#!/bin/bash

# Get the port from environment variable or default to 8080
PORT=${PORT:-8080}

# Create necessary directories and set permissions
mkdir -p /var/www/storage/logs
mkdir -p /var/www/storage/framework/cache
mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/framework/views

# Set proper permissions
chown -R www-data:www-data /var/www/storage
chmod -R 775 /var/www/storage

# Start PHP-FPM in background
echo "Starting PHP-FPM..."
php-fpm -D

# Wait a moment for PHP-FPM to start
sleep 3

echo "PHP-FPM started successfully"

# Update nginx config to use the correct port
sed -i "s/listen 8080/listen $PORT/g" /etc/nginx/nginx.conf

echo "Starting nginx on port $PORT..."
# Start nginx in foreground
nginx -g "daemon off;" 