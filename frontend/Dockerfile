# syntax=docker/dockerfile:1

# Build stage
FROM --platform=$BUILDPLATFORM node:20-alpine AS builder

WORKDIR /app

# Configure npm and Next.js
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm install -g npm@latest update-browserslist-db@latest && \
    npm config set update-notifier false && \
    npm config set fund false && \
    npm config set audit false

# Install dependencies
COPY frontend/package*.json ./
RUN npm ci

# Build application
COPY frontend/ ./
RUN npm run build

# Production stage
FROM --platform=linux/arm64 node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000
CMD ["npm", "start"]

# Build timestamp: 2025-01-25 17:24:19

# Build timestamp: 2025-01-25 17:27:03
