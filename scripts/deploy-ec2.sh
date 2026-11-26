#!/usr/bin/env bash
# Deploy Codes Thinker LMS API on EC2 (pull → migrate → build → PM2 restart).
# Usage (on EC2):
#   cd ~/codesthinkerlms-server && bash scripts/deploy-ec2.sh
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/codesthinkerlms-server}"
PM2_NAME="${PM2_NAME:-codesthinkerlms}"
BRANCH="${BRANCH:-main}"

cd "$APP_DIR"

echo "==> [1/6] git pull ($BRANCH)"
git fetch origin
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

echo "==> [2/6] npm install"
npm install --omit=dev=false

echo "==> [3/6] prisma generate + migrate deploy"
npx prisma generate
npx prisma migrate deploy

echo "==> [4/6] build"
npm run build

echo "==> [5/6] PM2 restart ($PM2_NAME)"
if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  pm2 restart "$PM2_NAME" --update-env
else
  # First-time / missing process
  pm2 start dist/main.js --name "$PM2_NAME" --cwd "$APP_DIR"
fi
pm2 save

echo "==> [6/6] health check"
sleep 2
pm2 status "$PM2_NAME"
curl -sf "http://127.0.0.1:${PORT:-3000}/health" && echo || \
  curl -sf "http://127.0.0.1:${PORT:-3000}/api/health" && echo || \
  echo "(health endpoint optional — check pm2 logs if needed)"

echo
echo "Done. Tail logs with:"
echo "  pm2 logs $PM2_NAME --lines 40"
