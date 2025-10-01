.PHONY: help install test run build docker-run clean

# Default target
help:
	@echo "MCP Open Pipe Analysis Server"
	@echo "=============================="
	@echo ""
	@echo "Available commands:"
	@echo "  make install     - Install Python dependencies"
	@echo "  make test        - Run router tests offline"
	@echo "  make run         - Start the server (dry run mode)"
	@echo "  make run-live    - Start the server (live mode)"
	@echo "  make build       - Build Docker image"
	@echo "  make docker-run  - Run in Docker container"
	@echo "  make clean       - Clean up temporary files"
	@echo ""
	@echo "Setup:"
	@echo "  1. Copy env.example to .env"
	@echo "  2. Edit .env with your Salesforce credentials"
	@echo "  3. Run 'make install' to install dependencies"
	@echo "  4. Run 'make test' to test the router"
	@echo "  5. Run 'make run' to start the server"

# Install dependencies
install:
	pip install -r requirements.txt

# Run router tests
test:
	python mcp_server.py --test

# Run server in dry-run mode
run:
	python mcp_server.py --port 8787

# Run server in live mode
run-live:
	python mcp_server.py --port 8787 --live

# Build Docker image
build:
	docker build -t openpipe-mcp .

# Run in Docker
docker-run:
	docker run -p 8787:8787 --env-file .env openpipe-mcp

# Clean up
clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
