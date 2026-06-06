#!/bin/bash
# deploy.sh - Run this script on your VPS after uploading the project
# Usage: bash deployment/deploy.sh

set -e

PROJECT_DIR="/home/portfolio/DJANGO-Portfolio-master"
VENV_DIR="/home/portfolio/venv"

echo "===> Activating virtual environment..."
source $VENV_DIR/bin/activate

echo "===> Installing/updating dependencies..."
pip install -r $PROJECT_DIR/requirements.txt

echo "===> Running migrations..."
cd $PROJECT_DIR
python manage.py migrate --no-input

echo "===> Collecting static files..."
python manage.py collectstatic --no-input

echo "===> Restarting Gunicorn..."
sudo systemctl restart gunicorn

echo "===> Reloading Nginx..."
sudo systemctl reload nginx

echo ""
echo "✅ Deployment complete!"
