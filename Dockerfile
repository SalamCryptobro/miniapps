FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./

# Install dependencies (use npm install to handle lock file conflicts)
RUN npm install

# Copy source code
COPY . .

# Build the application
RUN npm run build

FROM node:20-slim

WORKDIR /app

# Copy built application and package files
COPY --from=builder /app/build ./build
COPY --from=builder /app/package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Create non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

EXPOSE 3000

CMD ["npm", "start"]