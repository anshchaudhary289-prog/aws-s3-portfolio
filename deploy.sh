#!/usr/bin/env bash
# Deploy this static site to its S3 bucket.
#
# Usage:
#   S3_BUCKET=your-bucket-name ./deploy.sh
#   ./deploy.sh your-bucket-name
#
# Prerequisites:
#   - AWS CLI installed and configured (aws configure)
#   - Bucket already created, static website hosting enabled,
#     and bucket-policy.json applied (see README "Deployment" steps)
set -euo pipefail

BUCKET="${1:-${S3_BUCKET:-}}"
REGION="${AWS_REGION:-ap-south-1}"

if [[ -z "$BUCKET" ]]; then
  echo "Error: bucket name not set." >&2
  echo "Usage: S3_BUCKET=your-bucket-name ./deploy.sh   (or: ./deploy.sh your-bucket-name)" >&2
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "Error: AWS CLI not found. Install it and run 'aws configure' first." >&2
  exit 1
fi

# Always sync from the folder this script lives in, not the caller's cwd.
cd "$(dirname "$0")"

echo "Deploying $(pwd) -> s3://${BUCKET} (region: ${REGION})"

# --delete removes files in the bucket that no longer exist locally,
# so the live site never keeps stale pages.
# Cache note: browsers/CDNs may hold an old index.html for a while.
# For an instant refresh on the main page, the commented variant below
# re-uploads index.html with a short cache lifetime after the main sync.
aws s3 sync . "s3://${BUCKET}" \
  --region "$REGION" \
  --delete \
  --exclude ".git/*" \
  --exclude "README.md" \
  --exclude "deploy.sh" \
  --exclude "bucket-policy.json" \
  --exclude "docs/*" \
  --exclude ".gitignore"

# Optional instant-refresh for the landing page (uncomment if needed):
# aws s3 cp index.html "s3://${BUCKET}/index.html" \
#   --region "$REGION" \
#   --cache-control "max-age=60" \
#   --content-type "text/html"

echo "Done. Website endpoint (if static hosting is enabled):"
echo "  http://${BUCKET}.s3-website.${REGION}.amazonaws.com"
