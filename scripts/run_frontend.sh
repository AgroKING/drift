#!/bin/bash
echo '🌊 Starting Drift Frontend Dashboard Production Server...'
cd "$(dirname "$0")/../frontend/web" || exit
python -m http.server 8081
