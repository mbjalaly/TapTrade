# Stage 1: Build Flutter Web App
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get Flutter dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build Flutter web app
RUN flutter build web --release

# Stage 2: Serve with Node.js
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy the built web app from the previous stage
COPY --from=build /app/build/web ./web

# Copy server file
COPY server.js .
COPY package.json .

# Install Node dependencies
RUN npm install --production

# Expose port
EXPOSE 8080

# Start the server
CMD ["node", "server.js"]

