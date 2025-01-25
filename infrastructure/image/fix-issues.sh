#!/bin/bash

# Exit on error
set -e

echo "Fixing identified issues..."

# 1. Update browserslist database
echo "Updating browserslist database..."
npx update-browserslist-db@latest

# 2. Disable Next.js telemetry
echo "Disabling Next.js telemetry..."
npx next telemetry disable

# 3. Update package name in package.json
echo "Updating package name..."
sed -i '' 's/"auth0-b2b-saas-starter"/"archiverse"/g' ../../package.json

# 4. Update platform in Dockerfile
echo "Updating Dockerfile platform..."
sed -i '' '1s/^/# syntax=docker\/dockerfile:1\n/' ../../Dockerfile
sed -i '' '2i\
ARG TARGETPLATFORM=linux/arm64\n' ../../Dockerfile

# 5. Update npm
echo "Updating npm..."
npm install -g npm@latest

# 6. Update Flux sync interval
echo "Updating Flux sync interval..."
sed -i '' 's/interval: 10m0s/interval: 3m0s/' ../flux-system/gotk-sync.yaml

echo "All fixes applied!"
