# NAGP Frontend Application

This is the frontend application for the NAGP project, built with SvelteKit and Vite. This README provides all necessary information to set up, develop, and deploy the application.

## Prerequisites

- Node.js (v18 or later)
- npm (v9 or later) or yarn
- Docker (v20.10 or later)
- Docker Compose (v2.0 or later)


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


## How to run frontend docker container

### Important Note
Before starting the frontend docker container, make sure to start all the required backend microservices first using the commands provided in the Backend Services section below.

### Run Docker Container

```bash
docker run -d -p 3000:3000 --name nagp-frontend neha531/nagp-frontend:latest
```

### Deployed frontend app on vercel

Frontend app is deployed on vercel also. You can also access it from here. But make sure to run all the backend services as mentioned in the Backend Services section.

```bash
https://nagp-frontend.vercel.app/
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
