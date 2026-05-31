#!/bin/bash

# Exit on error
set -e

# Get script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "=================================================="
echo "🌊 Starting Drift: Developer Attention Debt Tracker"
echo "=================================================="

# Cleanup background processes on exit
cleanup() {
    echo ""
    echo "Stopping servers..."
    if [ -n "$FRONTEND_PID" ]; then kill $FRONTEND_PID 2>/dev/null || true; fi
    if [ -n "$REPORT_PID" ]; then kill $REPORT_PID 2>/dev/null || true; fi
    echo "Done. Bye!"
}
trap cleanup EXIT

# 1. Run backend scan to generate initial report
echo "🔄 Running initial backend scan..."
uv run --directory "$DIR/backend" python -m drift_agent scan --live

# 2. Start the report CORS server (port 8080)
echo "📶 Starting report CORS server on port 8080..."
cd "$DIR/backend/data"
python3 "$DIR/scripts/serve_cors.py" 8080 > /dev/null 2>&1 &
REPORT_PID=$!

# 3. Start the frontend server (port 8081)
echo "🖥️  Starting frontend web server on port 8081..."
cd "$DIR/frontend/web"
python3 -m http.server 8081 > /dev/null 2>&1 &
FRONTEND_PID=$!

echo "=================================================="
echo "🎉 Drift is fully running!"
echo "👉 Dashboard URL: http://localhost:8081"
echo "👉 Live Data URL: http://localhost:8080/drift_report.json"
echo "=================================================="
echo "Press [Ctrl+C] to stop all servers."

# Keep the script running to catch Ctrl+C and clean up
while true; do
    sleep 1
done
