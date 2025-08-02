# NAGP Frontend Application

This is the frontend application for the NAGP project, built with SvelteKit and Vite. This README provides all necessary information to set up, develop, and deploy the application.

## Prerequisites

- Node.js (v18 or later)
- npm (v9 or later) or yarn
- Docker (v20.10 or later)
- Docker Compose (v2.0 or later)

## Development Setup

### 1. Install Dependencies

```bash
npm install
# or
yarn install
```

### 2. Start Development Server

```bash
npm run dev
# or
yarn dev
```

The application will be available at `http://localhost:5173`

## Production Build

### 1. Build the Application

```bash
npm run build
# or
yarn build
```

### 2. Preview Production Build

```bash
npm run preview
# or
yarn preview
```

## Docker Setup

### Important Note
Before starting the frontend Docker container, make sure to start all the required backend microservices first using the commands provided in the Backend Services section below.

### Build Docker Image

```bash
# Build for current architecture
docker build -t nagp-frontend .

# Build for multiple architectures (requires Docker Buildx)
docker buildx build --platform linux/amd64,linux/arm64 -t nagp-frontend .
```

### Run Docker Container

```bash
docker run -d \
  --name nagp-frontend \
  -p 3000:3000 \
  -e NODE_ENV=production \
  nagp-frontend
```

## Backend Services

Before running the frontend container, you need to start the backend microservices using Docker Compose:

### First Time Setup

```bash
docker-compose -f docker-compose.consul.yml up --build
```

The `--build` flag ensures all Docker images are built from scratch.

### Running Existing Services

If you've already built the services before:

```bash
docker-compose -f docker-compose.consul.yml up
```

### Stopping Services

To stop all running services:

```bash
docker-compose -f docker-compose.consul.yml down
```

## Environment Variables

The following environment variables can be configured:

- `NODE_ENV`: Environment (development, production)
- `PORT`: Port to run the application (default: 3000)
- `API_URL`: Base URL for API requests (default: http://localhost:5000)

## Troubleshooting

- If you encounter port conflicts, make sure no other services are running on the required ports (3000 for frontend, 5000 for backend by default).
- Ensure all backend services are running before starting the frontend in production mode.
- For Docker-related issues, verify that Docker is running and you have sufficient permissions.

## License

This project is proprietary and confidential.
