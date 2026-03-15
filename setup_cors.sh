#!/bin/bash

# Script to setup CORS for Firebase Storage
# Usage: ./setup_cors.sh <bucket-name>

BUCKET_NAME=${1:-"appbandodientu-a940c.appspot.com"}

echo "Setting up CORS for Firebase Storage bucket: $BUCKET_NAME"
echo "Using CORS configuration from cors.json"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not installed."
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if cors.json exists
if [ ! -f "cors.json" ]; then
    echo "Error: cors.json file not found!"
    exit 1
fi

# Apply CORS configuration
echo "Applying CORS configuration..."
gcloud storage buckets update gs://$BUCKET_NAME --cors-file=cors.json

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ CORS configuration applied successfully!"
    echo ""
    echo "Note: It may take a few minutes for the changes to take effect."
    echo "If you're still seeing CORS errors, try:"
    echo "  1. Clear your browser cache"
    echo "  2. Wait a few minutes and refresh"
    echo "  3. Check that the bucket name is correct"
else
    echo ""
    echo "❌ Failed to apply CORS configuration."
    echo "Please check:"
    echo "  1. You are authenticated: gcloud auth login"
    echo "  2. You have the correct project selected: gcloud config set project <project-id>"
    echo "  3. The bucket name is correct: $BUCKET_NAME"
    exit 1
fi

