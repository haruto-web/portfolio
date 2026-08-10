# EC2 Deployment Guide

This project is a Laravel 12 portfolio with React assets built by Vite. These steps assume an Ubuntu EC2 instance using Nginx and PHP-FPM.

## 1. Connect to EC2

```bash
ssh -i /path/to/key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

## 2. Install server packages

```bash
sudo apt update
sudo apt install -y nginx git unzip curl software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.2 php8.2-fpm php8.2-cli php8.2-mbstring php8.2-xml php8.2-curl php8.2-zip php8.2-bcmath
```

Install Composer:

```bash
cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
composer --version
```

Install Node.js:

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
node --version
npm --version
```

## 3. Upload or clone the project

Clone from GitHub:

```bash
sudo mkdir -p /var/www
sudo chown ubuntu:ubuntu /var/www
cd /var/www
git clone YOUR_REPOSITORY_URL portfolio
cd portfolio
```

Or upload from your computer:

```bash
scp -i /path/to/key.pem -r . ubuntu@YOUR_EC2_PUBLIC_IP:/var/www/portfolio
```

## 4. Configure Laravel

```bash
cd /var/www/portfolio
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate
```

Edit `.env`:

```bash
nano .env
```

Use production values:

```env
APP_NAME="Ven Andrew Portfolio"
APP_ENV=production
APP_DEBUG=false
APP_URL=http://YOUR_EC2_PUBLIC_IP

LOG_CHANNEL=stack
LOG_LEVEL=error
SESSION_DRIVER=file
CACHE_STORE=file
```

If you have a domain, set `APP_URL=https://your-domain.com`.

## 5. Build frontend assets

```bash
npm ci
npm run build
```

## 6. Set permissions

```bash
sudo chown -R www-data:www-data /var/www/portfolio/storage /var/www/portfolio/bootstrap/cache
sudo chmod -R 775 /var/www/portfolio/storage /var/www/portfolio/bootstrap/cache
```

## 7. Configure Nginx

Create the site config:

```bash
sudo nano /etc/nginx/sites-available/portfolio
```

Paste this config:

```nginx
server {
    listen 80;
    server_name YOUR_EC2_PUBLIC_IP;
    root /var/www/portfolio/public;

    index index.php index.html;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Enable it:

```bash
sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/portfolio
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

## 8. Cache Laravel config

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 9. Open EC2 firewall

In the AWS EC2 security group, allow inbound:

- HTTP, port `80`, source `0.0.0.0/0`
- HTTPS, port `443`, source `0.0.0.0/0` if you add SSL
- SSH, port `22`, source your IP address

Then visit:

```text
http://YOUR_EC2_PUBLIC_IP
```

## Optional: Add SSL with a domain

Point your domain DNS `A` record to the EC2 public IP, then install Certbot:

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

After SSL is active, update `.env`:

```env
APP_URL=https://your-domain.com
```

Then refresh config:

```bash
php artisan config:cache
```

## Updating the site later

```bash
cd /var/www/portfolio
git pull
composer install --no-dev --optimize-autoloader
npm ci
npm run build
php artisan config:cache
php artisan route:cache
php artisan view:cache
sudo systemctl reload nginx
```
