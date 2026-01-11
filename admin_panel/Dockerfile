# TapTrade Admin Panel - Dockerfile
# This builds a Flutter Web app and serves it with Node.js

# Stage 1: Build Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build

WORKDIR /app

# Copy Flutter project files
COPY pubspec.yaml pubspec.lock ./
COPY lib ./lib
COPY web ./web

# Get dependencies and build
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Node.js
FROM node:18-alpine AS production

WORKDIR /app

# Copy package files and install dependencies
COPY package.json ./
RUN npm install --production

# Copy server and built web files
COPY server.js ./
COPY --from=flutter-build /app/build/web ./build/web

# Expose port
EXPOSE 8080
ENV PORT=8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Start server
CMD ["node", "server.js"]
