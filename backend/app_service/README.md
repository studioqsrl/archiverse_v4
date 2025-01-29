# App Service

A FastAPI-based service that provides data from PostgreSQL to the frontend dashboard.

## Features

- PostgreSQL data access and querying
- RESTful API endpoints
- Health check monitoring
- Authentication via Auth0 tokens
- Docker containerization

## Development

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set environment variables:
```bash
POSTGRES_HOST=localhost  # Default: postgres
POSTGRES_DB=archiverse  # Default: archiverse
POSTGRES_USER=postgres  # Default: postgres
POSTGRES_PASSWORD=your_password
```

3. Run the development server:
```bash
uvicorn app:app --reload
```

## API Endpoints

- `GET /health`: Health check endpoint
- `GET /api/data`: Retrieve sample data from PostgreSQL

## Docker

Build the container:
```bash
docker build -t app-service .
```

Run locally:
```bash
docker run -p 8000:8000 app-service
```

## Deployment

The service is deployed to Kubernetes using the configuration in `infrastructure/k8s/base/app-service.yaml`. It uses the same node pool as the frontend service and communicates with PostgreSQL through internal cluster networking.
# Test comment
# Test comment
# Another test comment
# Test comment
