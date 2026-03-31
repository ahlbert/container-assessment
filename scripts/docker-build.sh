#!/bin/bash

# Docker Build Script for MuchTodo Backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}MuchTodo Backend - Docker Build${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Configuration
IMAGE_NAME="muchtodo-backend"
IMAGE_TAG="${1:-latest}"
REGISTRY="${2:-}"  # Optional: Docker registry (e.g., docker.io/username)

if [ -n "$REGISTRY" ]; then
    FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
else
    FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
fi

echo -e "${YELLOW}Building Docker image...${NC}"
echo -e "Image: ${GREEN}${FULL_IMAGE_NAME}${NC}"
echo ""

# Build the Docker image
docker build \
    --tag "${FULL_IMAGE_NAME}" \
    --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --build-arg VCS_REF="$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')" \
    --file Dockerfile \
    .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Docker image built successfully!${NC}"
    echo -e "Image: ${FULL_IMAGE_NAME}"
    
    # Show image size
    IMAGE_SIZE=$(docker images "${FULL_IMAGE_NAME}" --format "{{.Size}}")
    echo -e "Size: ${IMAGE_SIZE}"
    
    # Optional: Tag as latest
    if [ "${IMAGE_TAG}" != "latest" ]; then
        echo ""
        echo -e "${YELLOW}Tagging image as 'latest'...${NC}"
        if [ -n "$REGISTRY" ]; then
            docker tag "${FULL_IMAGE_NAME}" "${REGISTRY}/${IMAGE_NAME}:latest"
        else
            docker tag "${FULL_IMAGE_NAME}" "${IMAGE_NAME}:latest"
        fi
    fi
    
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "  1. Test locally: ${YELLOW}docker run -p 8000:8080 ${FULL_IMAGE_NAME}${NC}"
    echo -e "  2. Run with compose: ${YELLOW}./scripts/docker-run.sh${NC}"
    
    if [ -n "$REGISTRY" ]; then
        echo -e "  3. Push to registry: ${YELLOW}docker push ${FULL_IMAGE_NAME}${NC}"
    fi
    
else
    echo ""
    echo -e "${RED}✗ Docker build failed!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Build complete!${NC}"
