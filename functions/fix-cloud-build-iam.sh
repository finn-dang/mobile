#!/usr/bin/env bash
# Sửa lỗi: "Could not build the function due to a missing permission
# on the build service account" khi deploy Cloud Functions Gen2 (Firebase).
#
# Chạy một lần (cần gcloud đăng nhập & quyền Owner/Editor trên project):
#   chmod +x fix-cloud-build-iam.sh && ./fix-cloud-build-iam.sh
#
# Sau đó:
#   cd .. && firebase deploy --only functions:productChatbot
#
# Nên dùng Firebase CLI mới (tránh URL cleanup .../undefined/gcf):
#   npm i -g firebase-tools@latest

set -euo pipefail

PROJECT_ID="${GCLOUD_PROJECT:-figurestore-68028}"
PROJECT_NUMBER="${GCLOUD_PROJECT_NUMBER:-$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')}"

CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo "Project: ${PROJECT_ID} (number: ${PROJECT_NUMBER})"

echo "==> Artifact Registry + logging cho Cloud Build SA"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/logging.logWriter"

echo "==> Cloud Build được dùng Compute default SA khi build (serviceAccountUser)"
gcloud iam service-accounts add-iam-policy-binding "${COMPUTE_SA}" \
  --project="${PROJECT_ID}" \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/iam.serviceAccountUser"

echo "==> (Khuyến nghị GCP) Gán cloudbuild.builds.builder cho Compute SA"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${COMPUTE_SA}" \
  --role="roles/cloudbuild.builds.builder"

echo "==> Truy cập Secret Manager khi deploy function có secrets"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/secretmanager.secretAccessor"

echo "Xong. Deploy lại: firebase deploy --only functions:productChatbot"
