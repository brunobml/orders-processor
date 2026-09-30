.PHONY: all build push build-and-push run-local test help

TAG ?= v1.1.0
REGISTRY ?= ghcr.io/brunobml
IMAGE_NAME ?= orders-processor
FULL_IMAGE ?= $(REGISTRY)/$(IMAGE_NAME):$(TAG)

all: help

help:
	@echo "Orders Processor Microservice Commands:"
	@echo "  make build          - Build Docker image ($(FULL_IMAGE))"
	@echo "  make push           - Push Docker image to registry ($(FULL_IMAGE))"
	@echo "  make build-and-push - Build and push in one step (TAG=$(TAG))"
	@echo "  make run-local      - Run the container locally connecting to Moto Cloud"
	@echo "  make test           - Run unit tests / syntax checks"

build:
	@echo "🔨 Building $(FULL_IMAGE)..."
	docker build -t $(FULL_IMAGE) .

push:
	@echo "🚀 Pushing $(FULL_IMAGE)..."
	docker push $(FULL_IMAGE)

build-and-push:
	@bash build-and-push.sh $(TAG)

test:
	@echo "🧪 Running syntax verification..."
	python3 -m py_compile src/main.py
	@echo "✔ Code syntax valid"

run-local:
	@echo "🌐 Running $(FULL_IMAGE) on port 8080..."
	docker run --rm -it \
		-p 8080:8080 \
		-e QUEUE_URL="http://localhost:5000/123456789012/orders-dev-queue" \
		-e MOTO_ENDPOINT="http://localhost:5000" \
		-e ENVIRONMENT="local" \
		-e APP_NAME="orders" \
		$(FULL_IMAGE)
