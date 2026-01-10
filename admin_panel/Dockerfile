# Stage 1: Build Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Node.js
FROM node:18-alpine

WORKDIR /app

COPY package.json .
RUN npm install --production

COPY server.js .
COPY --from=build /app/build/web ./build/web

EXPOSE 8080

CMD ["node", "server.js"]

