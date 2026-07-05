# Stage 1: Build the application
FROM node:22-alpine AS builder

WORKDIR /app

# Copy dependency configuration files
COPY package*.json ./

# Install all dependencies (including devDependencies for the build phase)
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copy the rest of the application source code and data files
COPY . .

# Run the build script (compiles frontend assets and bundles server.ts to dist/server.cjs)
RUN npm run build

# Stage 2: Production environment
FROM node:22-alpine AS runner

WORKDIR /app

# Set runtime environment variables
ENV NODE_ENV=production

# Copy package configuration files and install only production dependencies
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi

# Copy compiled dist files from the builder stage
COPY --from=builder /app/dist ./dist

# Create empty data directory (server.ts will populate it dynamically on startup)
RUN mkdir -p data

# Expose port 8080
EXPOSE 8080

# Start the application using our production command
CMD ["npm", "start"]
