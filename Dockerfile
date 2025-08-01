# Stage 1: Build the application
FROM node:20-alpine as build

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
COPY .npmrc ./
RUN npm ci

# Install node adapter for SvelteKit
RUN npm install --save-dev @sveltejs/adapter-node

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Create the runtime image
FROM node:20-alpine

WORKDIR /app

# Copy package files and install only production dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy the built application
COPY --from=build /app/build ./

# Copy static files if any
COPY static ./static

# Expose the port the app runs on
EXPOSE 3000

# Set environment to production
ENV NODE_ENV=production

# Start the application
CMD ["node", "."]
