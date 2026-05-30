#!/bin/bash
# Get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="$(dirname "$DIR")"

echo "Serving drift report on http://localhost:8080/drift_report.json"
cd "$ROOT_DIR/backend/data"
python "$DIR/serve_cors.py" 8080
