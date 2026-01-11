FROM node:20-alpine

WORKDIR /app

# Copy backend files from subdirectory
COPY backend/package*.json ./

RUN npm ci

COPY backend/tsconfig.json ./
COPY backend/src ./src

RUN npm run build

ENV NODE_ENV=production
EXPOSE 3001

CMD ["npm", "run", "start"]

