# Orders Processor Microservice

A cloud-native Python microservice that provides an HTTP web dashboard for order management, publishes orders to AWS SQS queues, and processes messages asynchronously with distributed state tracking in DynamoDB.

Deployed across Kubernetes environments (`dev`, `test`, `prod`) using **Kro ResourceGraphDefinitions** and **Argo CD GitOps**.

---

## 🏗 Architecture

```
                  ┌──────────────────────┐
                  │ Web Browser / Client │
                  └──────────┬───────────┘
                             │
                             ▼ (HTTP Ingress)
             ┌────────────────────────────────┐
             │ Orders Processor (Fast Python) │
             │  - HTTP Web Dashboard (:8080)  │
             │  - Background SQS Worker Thread │
             └──────┬──────────────────┬──────┘
     (Publish Order)│                  │(Save Processed)
                    ▼                  ▼
             ┌──────────────┐   ┌──────────────┐
             │   AWS SQS    │   │ AWS DynamoDB │
             │ (Ack/Queue)  │   │(Shared Table)│
             └──────────────┘   └──────────────┘
```

- **HTTP Web Dashboard**:
  - `GET /`: Displays microservice status, connected SQS queue, serving pod ID, and live order feed.
  - `GET /healthz`: Kubernetes liveness / readiness probe.
  - `POST /order`: Accepts form-encoded order payloads and publishes them directly to the SQS queue.
- **Asynchronous Worker Thread**:
  - Long-polls the SQS queue via SigV4 AWS REST protocol.
  - Consumes and deletes processed messages.
  - Writes processed orders with pod IDs and timestamps to a shared DynamoDB table (`orders-<env>-history`), ensuring multi-replica consistency.

---

## 🚀 Building & Publishing

### Prerequisites
- Docker
- Local k3d Private Registry running on `localhost:5001` (or your company's OCI registry)

### Build and Push
```bash
# Build and push default version (v1.0.0)
make build-and-push

# Build and push a custom tag
make build-and-push TAG=v1.1.0
```

### Local Testing
```bash
# Verify syntax
make test

# Run container locally against local Moto cloud
make run-local
```

---

## 🚢 GitOps Deployment

This application is deployed via GitOps:
- **GitOps Config Repository**: [`tenant-workloads`](https://github.com/brunobml/tenant-workloads)
  - `tenants/tenant-a/dev/orders-service.yaml`
  - `tenants/tenant-a/test/orders-service.yaml`
  - `tenants/tenant-a/prod/orders-service.yaml`
- **Platform Infrastructure Blueprint**: [`platform-catalog`](https://github.com/brunobml/platform-catalog)
  - `blueprints/message-processor-rgd.yaml` (Kro ResourceGraphDefinition)
- **GitOps Control Plane**: [`gitops-control-plane`](https://github.com/brunobml/gitops-control-plane)
