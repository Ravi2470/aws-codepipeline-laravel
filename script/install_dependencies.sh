#!/bin/bash

# Exit on error
set -o errexit -o pipefail

# Update yum
sudo apt update -y

# Install packages
sudo apt install -y curl
sudo apt install -y git

# Remove current apache & php
sudo apt -y remove apache2* php*

# Install PHP 7.1
sudo apt install -y php71 php71-cli php71-fpm php71-mysql php71-xml php71-curl php71-opcache php71-pdo php71-gd php71-pecl-apcu php71-mbstring php71-imap php71-pecl-redis php71-mcrypt php71-mysqlnd mod24_ssl

# Install Apache 2.4
sudo apt -y install apache2

# Allow URL rewrites
sed -i 's#AllowOverride None#AllowOverride All#' /etc/apache2/apache2.conf


# Change apache document root
mkdir -p /var/www/html/public
sed -i 's#DocumentRoot "/var/www/html"#DocumentRoot "/var/www/html/public"#' /etc/apache2/apache2.conf

# Change apache directory index
sed -e 's/DirectoryIndex.*/DirectoryIndex index.html index.php/' -i /etc/apache2/apache2.conf

# Get Composer, and install to /usr/local/bin
if [ ! -f "/usr/local/bin/composer" ]; then
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --install-dir=/usr/bin --filename=composer
    php -r "unlink('composer-setup.php');"
else
    /usr/local/bin/composer self-update --stable --no-ansi --no-interaction
fi

# Restart apache
systemctl start apache2

# Setup apache to start on boot
systemctl enable apache2

# Ensure aws-cli is installed and configured
if [ ! -f "/usr/bin/aws" ]; then
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    ./awscli-bundle/install -b /usr/bin/aws
fi

# Ensure AWS Variables are available
if [[ -z "$AWS_ACCOUNT_ID" || -z "$AWS_DEFAULT_REGION " ]]; then
    echo "AWS Variables Not Set.  Either AWS_ACCOUNT_ID or AWS_DEFAULT_REGION"
fi
