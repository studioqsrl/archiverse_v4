# syntax=docker/dockerfile:1

# Build stage
FROM --platform=$BUILDPLATFORM node:20-alpine AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM

WORKDIR /app

# Configure npm and Next.js
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm install -g npm@latest && \
    npm config set update-notifier false && \
    npm config set fund false && \
    npm config set audit false

# Install dependencies
COPY package*.json ./
RUN npm ci && \
    npx update-browserslist-db@latest --yes

# Build application
COPY . .
RUN npm run build

# Production stage
FROM --platform=$TARGETPLATFORM node:20-alpine AS runner
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
