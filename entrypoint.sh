#!/bin/bash
set -e

echo "⏳ Waiting for MySQL to be ready at $MYSQL_HOST:$MYSQL_PORT..."

until mysqladmin ping -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    >&2 echo "❗ MySQL not yet available, waiting..."
    sleep 2
done

echo "✅ MySQL is up!"

echo "📝 Running database migrations..."
python manage.py migrate --noinput || {
    echo "❌ Migration failed."
    exit 1
}

echo "🎛️ Collecting static files..."
python manage.py collectstatic --noinput

echo "🚀 Starting Gunicorn server..."
exec gunicorn  --certfile=certs/secure.crt  --keyfile=certs/secure.key  --bind=0.0.0.0:8000  django_project.wsgi:application  --workers=3
