#!/usr/bin/env bash
set -e

echo "======================================"
echo "Starting Applio for RunPod"
echo "======================================"

mkdir -p /workspace

cd /opt/Applio
source .venv/bin/activate

echo "Killing old Applio processes if any..."
pkill -f "python.*app.py" || true

echo "Starting Applio on local port 6969..."
python -u app.py > /workspace/applio.log 2>&1 &

APP_PID=$!

echo "Waiting for Applio..."
sleep 15

echo "====== Applio log preview ======"
tail -n 80 /workspace/applio.log || true
echo "================================"

if ! ps -p "$APP_PID" > /dev/null; then
    echo "Applio crashed. Full log:"
    cat /workspace/applio.log || true
    exit 1
fi

echo "Checking listening ports..."
ss -ltnp || true

echo "======================================"
echo "Cloudflare tunnel is starting now."
echo "Open the trycloudflare.com link below."
echo "======================================"

exec cloudflared tunnel --url http://127.0.0.1:6969
