@echo off
setlocal
color 0A

echo.
echo ===============================================
echo === PORTFOLIO DEPLOYMENT TO EC2 ===
echo ===============================================
echo.

REM EC2 details
set PEM_KEY=D:\k677key.pem
set EC2_USER=ec2-user
set EC2_HOST=13.250.47.185
set REMOTE_PATH=/var/www/portfolio
set ARCHIVE_NAME=portfolio-deploy.tar.gz

if not exist "%PEM_KEY%" (
    echo ERROR: PEM key not found at %PEM_KEY%
    pause
    exit /b 1
)

echo [STEP 1/5] Building Vite assets...
call npm run build
if errorlevel 1 (
    echo ERROR: Build failed
    pause
    exit /b 1
)
echo Build complete

echo.
echo [STEP 2/5] Creating deployment archive...
if exist "%ARCHIVE_NAME%" del "%ARCHIVE_NAME%"

tar ^
  --exclude="./.git" ^
  --exclude="./.agents" ^
  --exclude="./node_modules" ^
  --exclude="./vendor" ^
  --exclude="./storage/logs/*" ^
  --exclude="./storage/framework/cache/*" ^
  --exclude="./storage/framework/sessions/*" ^
  --exclude="./storage/framework/views/*" ^
  --exclude="./%ARCHIVE_NAME%" ^
  -czf "%ARCHIVE_NAME%" .

if errorlevel 1 (
    echo ERROR: Could not create deployment archive
    pause
    exit /b 1
)
echo Archive created

echo.
echo [STEP 3/5] Preparing EC2 directory...
ssh -i "%PEM_KEY%" %EC2_USER%@%EC2_HOST% "sudo mkdir -p %REMOTE_PATH% && sudo chown -R %EC2_USER%:%EC2_USER% %REMOTE_PATH%"
if errorlevel 1 (
    echo ERROR: Could not prepare EC2 directory
    pause
    exit /b 1
)
echo EC2 directory ready

echo.
echo [STEP 4/5] Uploading archive to EC2...
scp -i "%PEM_KEY%" "%ARCHIVE_NAME%" %EC2_USER%@%EC2_HOST%:/tmp/%ARCHIVE_NAME%
if errorlevel 1 (
    echo ERROR: Upload failed
    pause
    exit /b 1
)
echo Upload complete

echo.
echo [STEP 5/5] Extracting and refreshing Laravel on EC2...
ssh -i "%PEM_KEY%" %EC2_USER%@%EC2_HOST% "sudo chown -R %EC2_USER%:%EC2_USER% %REMOTE_PATH% && cd %REMOTE_PATH% && tar -xzf /tmp/%ARCHIVE_NAME% && rm -f /tmp/%ARCHIVE_NAME% && composer install --no-dev --optimize-autoloader && test -f .env || (cp .env.example .env && php artisan key:generate --force) && mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache && php artisan config:clear && php artisan route:clear && php artisan view:clear && php artisan cache:clear && php artisan config:cache && php artisan route:cache && php artisan view:cache && sudo chown -R apache:apache storage bootstrap/cache && sudo systemctl restart php-fpm && sudo systemctl restart nginx"

if errorlevel 1 (
    echo WARNING: Deployment uploaded, but one or more EC2 commands failed.
    echo Check PHP-FPM service name, Nginx config, and folder permissions on EC2.
) else (
    echo Deployment complete
)

if exist "%ARCHIVE_NAME%" del "%ARCHIVE_NAME%"

echo.
echo ===============================================
echo DEPLOYMENT FINISHED
echo ===============================================
echo.
echo Website: http://13.250.47.185
echo.
pause
