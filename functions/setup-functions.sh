#!/usr/bin/env bash
set -e

# --- configuration: replace these ---
PROJECT_ID="landandplot-v2"
ALIAS="staging"        # or dev, prod, whatever you like
# -------------------------------

LOG_FILE="./setup.log"

# ensure functions/ exists so we can write the log there
mkdir -p functions

# redirect all output (stdout+stderr) to the log
exec >"$LOG_FILE" 2>&1

echo "=== Starting Firebase Functions setup ==="
echo "Timestamp: $(date)"

echo
echo "--- Installing Firebase CLI globally ---"
npm install -g firebase-tools

echo
echo "--- Logging in to Firebase ---"
firebase login --no-localhost

echo
echo "--- Adding project alias ($ALIAS) for $PROJECT_ID ---"
firebase use --add --alias "$ALIAS" --project "$PROJECT_ID"

echo
echo "--- Initializing functions directory ---"
firebase init functions --project "$PROJECT_ID" --yes

echo
echo "--- Installing functions dependencies ---"
cd functions
npm install

echo
echo "=== Done! Check $LOG_FILE for details ==="
