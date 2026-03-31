#!/bin/bash

# Docker Compose Run Script for MuchTodo

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}MuchTodo - Docker Compose${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}✗ Docker Compose is not installed!${NC}"
    echo "Install from: https://docs.docker.com/compose/install/"
    exit 1
fi

# Determine docker compose command
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo -e "${GREEN}✓ Docker Compose found${NC}"
echo ""

# Parse command
COMMAND="${1:-up}"

case "$COMMAND" in
    up|start)
        echo -e "${YELLOW}Starting services...${NC}"
        $COMPOSE_CMD up -d
        
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✓ Services started successfully!${NC}"
            echo ""
            echo -e "${BLUE}Service Status:${NC}"
            $COMPOSE_CMD ps
            
            echo ""
            echo -e "${BLUE}Waiting for services to be healthy...${NC}"
            sleep 5
            
            echo ""
            echo -e "${GREEN}Access your application:${NC}"
            echo -e "  Backend API: ${YELLOW}http://localhost:8080${NC}"
            echo -e "  Health Check: ${YELLOW}http://localhost:8080/health${NC}"
            echo -e "  MongoDB: ${YELLOW}mongodb://admin:admin123@localhost:27017${NC}"
            
            echo ""
            echo -e "${BLUE}Useful commands:${NC}"
            echo -e "  View logs: ${YELLOW}$COMPOSE_CMD logs -f${NC}"
            echo -e "  Stop services: ${YELLOW}./scripts/docker-run.sh stop${NC}"
            echo -e "  Restart: ${YELLOW}./scripts/docker-run.sh restart${NC}"
        fi
        ;;
        
    down|stop)
        echo -e "${YELLOW}Stopping services...${NC}"
        $COMPOSE_CMD down
        echo -e "${GREEN}✓ Services stopped${NC}"
        ;;
        
    restart)
        echo -e "${YELLOW}Restarting services...${NC}"
        $COMPOSE_CMD restart
        echo -e "${GREEN}✓ Services restarted${NC}"
        ;;
        
    logs)
        echo -e "${YELLOW}Showing logs (Ctrl+C to exit)...${NC}"
        $COMPOSE_CMD logs -f
        ;;
        
    ps|status)
        echo -e "${BLUE}Service Status:${NC}"
        $COMPOSE_CMD ps
        ;;
        
    build)
        echo -e "${YELLOW}Building services...${NC}"
        $COMPOSE_CMD build --no-cache
        echo -e "${GREEN}✓ Build complete${NC}"
        ;;
        
    clean)
        echo -e "${RED}Cleaning up (removing containers and volumes)...${NC}"
        read -p "Are you sure? This will delete all data! (yes/no): " CONFIRM
        if [ "$CONFIRM" = "yes" ]; then
            $COMPOSE_CMD down -v
            echo -e "${GREEN}✓ Cleanup complete${NC}"
        else
            echo -e "${YELLOW}Cleanup cancelled${NC}"
        fi
        ;;
        
    test)
        echo -e "${YELLOW}Testing application...${NC}"
        
        # Wait for backend to be ready
        echo "Waiting for backend to be ready..."
        for i in {1..30}; do
            if curl -sf http://localhost:8000/health > /dev/null; then
                echo -e "${GREEN}✓ Backend is healthy!${NC}"
                break
            fi
            echo -n "."
            sleep 1
        done
        
        echo ""
        echo -e "${BLUE}Testing endpoints:${NC}"
        
        # Test health endpoint
        echo -n "Health check: "
        if curl -sf http://localhost:8000/health > /dev/null; then
            echo -e "${GREEN}✓ PASS${NC}"
        else
            echo -e "${RED}✗ FAIL${NC}"
        fi
        ;;
        
    *)
        echo -e "${YELLOW}Usage:${NC} $0 {up|down|restart|logs|ps|build|clean|test}"
        echo ""
        echo "Commands:"
        echo "  up/start  - Start all services"
        echo "  down/stop - Stop all services"
        echo "  restart   - Restart all services"
        echo "  logs      - Show logs (follow mode)"
        echo "  ps/status - Show service status"
        echo "  build     - Rebuild services"
        echo "  clean     - Remove containers and volumes"
        echo "  test      - Test application endpoints"
        exit 1
        ;;
esac

echo ""
