#!/bin/bash
# Pocket Gull - Automated Google Cloud Run Deployment Script
# Required for Gemini Live Agent Challenge Infrastructure-as-Code Bonus

set -e

echo "=========================================================="
echo "🚀 Deploying Pocket Gull to Google Cloud Run"
echo "=========================================================="

# 1. Ensure gcloud is initialized and authenticated
# gcloud auth login
# gcloud config set project YOUR_PROJECT_ID

# Deploying to the explicit Understory project as per user instruction
PROJECT_ID="pgbizastroidx"

SERVICE_NAME="understory"
REGION="us-west1"
IMAGE_TAG="gcr.io/$PROJECT_ID/$SERVICE_NAME:latest"

echo "📦 1/3: Building the image for Cloud Run using Buildpacks..."
# Assuming Google Cloud Build is enabled for the project
gcloud builds submit --pack image=$IMAGE_TAG

echo "🌐 2/3: Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_TAG \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --memory 1Gi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 5

echo "✅ 3/3: Deployment Complete!"
echo "Your live agent is now running on Google Cloud."
echo "=========================================================="
