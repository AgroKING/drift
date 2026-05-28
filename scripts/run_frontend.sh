#!/bin/bash
echo '🌊 Starting Drift Frontend Dashboard Production Server...'
cd "$(dirname "$0")/../frontend/build/web" || exit
python -m http.server 8080
