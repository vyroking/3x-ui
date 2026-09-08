#!/bin/bash
set -Eeuo pipefail

echo "🚀 Starting 3x-ui + nginx..."

# Lucity/Railway normally provides PORT.
# Keep 3000 only as a local fallback.
NGINX_PORT="${PORT:-3000}"
export NGINX_PORT

if ! [[ "$NGINX_PORT" =~ ^[0-9]+$ ]] || [ "$NGINX_PORT" -lt 1 ] || [ "$NGINX_PORT" -gt 65535 ]; then
    echo "❌ Invalid PORT: $NGINX_PORT"
    exit 1
fi

cd /usr/local/x-ui

echo "🔧 Configuring 3x-ui on internal port 2053..."
./x-ui setting -port 2053 -webBasePath /managepanel/ || true

echo "🔧 Generating nginx config on port $NGINX_PORT..."
envsubst '${NGINX_PORT}' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

echo "🔍 Testing nginx configuration..."
nginx -t

echo "▶️ Starting 3x-ui..."
./x-ui &
X_UI_PID=$!

# If x-ui dies, stop the container instead of leaving a broken nginx-only process.
(
    wait "$X_UI_PID"
    code=$?
    echo "❌ 3x-ui exited with code $code"
    kill -TERM "$$" 2>/dev/null || true
) &

sleep 3

if ! kill -0 "$X_UI_PID" 2>/dev/null; then
    echo "❌ 3x-ui failed to start."
    exit 1
fi

echo "▶️ Starting nginx on $NGINX_PORT..."
exec nginx -g "daemon off;"
