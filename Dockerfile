# syntax=docker/dockerfile:1.4

# Stage 1: Build the application
# Using explicit platform from build arg with fallback to linux/amd64
FROM --platform=$BUILDPLATFORM node:20-alpine as build

# Set build arguments for architecture-specific configurations
ARG TARGETARCH
ARG TARGETOS

WORKDIR /app

# Install build dependencies including Python and build tools for native modules
RUN apk add --no-cache \
    python3 \
    make \
    g++

# Copy package files and install dependencies
COPY package*.json ./
COPY .npmrc ./

# Install dependencies with frozen lockfile and clean cache in one layer
RUN npm ci --prefer-offline --no-audit --progress=false && \
    npm cache clean --force

# Install node adapter for SvelteKit
RUN npm install --save-dev @sveltejs/adapter-node

# Copy source code
COPY . .

# Set build arguments as environment variables
ENV NODE_ENV=production
ENV TARGETARCH=${TARGETARCH}
ENV TARGETOS=${TARGETOS}

# Build the application with Vite
RUN npm run build

# Stage 2: Create the runtime image
FROM --platform=$TARGETPLATFORM node:20-alpine

# Set build arguments for runtime
ARG TARGETARCH
ARG TARGETOS

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache tini

# Copy package files and install only production dependencies
COPY package*.json package-lock*.json ./
RUN npm ci --omit=dev --prefer-offline --no-audit --progress=false && \
    npm cache clean --force

# Copy the built application from build stage
COPY --from=build /app/build ./

# Copy static files if any
COPY static ./static

# Expose the port the app runs on
EXPOSE 3000

# Set environment to production
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

# Use tini as the init process for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start the application
CMD ["node", "."]

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1
