# Docker Commands Guide

## Quick Start - Run Everything

### Option 1: Build and Run All Services (Recommended)
```bash
# Build and start all services (Redis, Backend, Frontend)
docker-compose up --build

# Or run in detached mode (background)
docker-compose up --build -d
```

### Option 2: Build First, Then Run
```bash
# Build all images
docker-compose build

# Start all services
docker-compose up

# Or start in detached mode
docker-compose up -d
```

## Access Your Application

After starting, access:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5001
- **Health Check**: http://localhost:5001/api/v1/health
- **Redis**: localhost:6379

## Useful Commands

### View Running Containers
```bash
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f redis
```

### Stop Services
```bash
# Stop all services
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop, remove containers, and volumes (removes Redis data)
docker-compose down -v
```

### Restart Services
```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart backend
docker-compose restart frontend
```

### Rebuild After Code Changes
```bash
# Rebuild and restart
docker-compose up --build

# Rebuild specific service
docker-compose build backend
docker-compose build frontend
docker-compose up -d
```

### Execute Commands in Containers
```bash
# Access backend container shell
docker-compose exec backend sh

# Access frontend container shell
docker-compose exec frontend sh

# Run npm commands in backend
docker-compose exec backend npm install

# Check backend health
docker-compose exec backend node -e "require('http').get('http://localhost:5001/api/v1/health', (r) => console.log(r.statusCode))"
```

## Individual Service Commands

### Run Only Backend + Redis
```bash
docker-compose up backend redis
```

### Run Only Frontend
```bash
docker-compose up frontend
```

## Troubleshooting

### Check Container Status
```bash
docker-compose ps
docker ps -a
```

### View Container Logs
```bash
docker-compose logs backend
docker-compose logs frontend
docker-compose logs redis
```

### Remove Everything and Start Fresh
```bash
# Stop and remove all containers, networks, and volumes
docker-compose down -v

# Remove all images
docker-compose rm -f

# Rebuild from scratch
docker-compose build --no-cache
docker-compose up
```

### Check if Ports are Available
```bash
# Check if ports are in use
lsof -i :5001  # Backend
lsof -i :3000  # Frontend
lsof -i :6379  # Redis
```

### Force Rebuild
```bash
docker-compose build --no-cache
docker-compose up
```

## Environment Variables

Make sure your `backend/config/config.env` file has all required variables:
- PORT=5001
- MONGO_URI=...
- JWT_SECRET=...
- REDIS_HOST=redis (automatically set by docker-compose)
- REDIS_PORT=6379 (automatically set by docker-compose)
- FRONTEND_URL=http://localhost:3000

## Production Build

For production, the frontend is built during Docker image creation.
The build output is served by nginx on port 80 (mapped to 3000 on host).

