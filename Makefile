# =========================
# Configuration
# =========================
CLUSTER_NAME := local-https
K3D_CONFIG   := k3d-local-https.yaml

APP_NAME     := myapp
APP_HOST     := myapp.localhost
NAMESPACE    := default

# Docker
IMAGE_NAME   := $(APP_NAME)
IMAGE_TAG    := local
IMAGE        := $(IMAGE_NAME):$(IMAGE_TAG)
DOCKERFILE   := Dockerfile
PLATFORM     := linux/amd64

# Kubernetes manifests
INGRESS      := myapp-ingress.yaml
CERT         := myapp-cert.yaml
ISSUER       := local-ca.yaml

# =========================
# Phony Targets
# =========================
.PHONY: help cluster-up cluster-down ingress cert-manager \
        ca cert build load deploy rebuild status clean reset

help:
	@echo ""
	@echo "Available targets:"
	@echo "  cluster-up      Create k3d cluster"
	@echo "  cluster-down    Delete k3d cluster"
	@echo "  ingress         Install NGINX Ingress Controller"
	@echo "  cert-manager    Install cert-manager"
	@echo "  ca              Create local self-signed CA"
	@echo "  cert            Create HTTPS certificate"
	@echo "  build           Build Docker image"
	@echo "  load            Load image into k3d"
	@echo "  deploy          Deploy app + ingress"
	@echo "  rebuild         Build → load → deploy"
	@echo "  status          Show cluster status"
	@echo "  clean           Remove app resources"
	@echo "  reset           Full reset (⚠️ destructive)"
	@echo ""

# =========================
# Cluster
# =========================
cluster-up:
	k3d cluster create --config $(K3D_CONFIG)

cluster-down:
	k3d cluster delete $(CLUSTER_NAME)

# =========================
# Ingress Controller
# =========================
ingress:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
	kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx

# =========================
# cert-manager
# =========================
cert-manager:
	kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
	kubectl rollout status deployment/cert-manager -n cert-manager
	kubectl rollout status deployment/cert-manager-webhook -n cert-manager

# =========================
# Local CA + Certificate
# =========================
ca:
	kubectl apply -f $(ISSUER)

cert:
	kubectl apply -f $(CERT)

# =========================
# Docker Image
# =========================
build:
	docker build \
		--platform $(PLATFORM) \
		-t $(IMAGE) \
		-f $(DOCKERFILE) .

load:
	k3d image import $(IMAGE) -c $(CLUSTER_NAME)

# =========================
# App Deployment
# =========================
deploy:
	kubectl apply -f k8s/
	kubectl apply -f $(INGRESS)

rebuild: build load deploy

# =========================
# Utilities
# =========================
status:
	@echo "Nodes:"
	kubectl get nodes
	@echo ""
	@echo "Pods:"
	kubectl get pods -A
	@echo ""
	@echo "Ingress:"
	kubectl get ingress
	@echo ""
	@echo "Certificates:"
	kubectl get certificates

clean:
	kubectl delete -f $(INGRESS) --ignore-not-found
	kubectl delete -f k8s/ --ignore-not-found

reset: clean cluster-down cluster-up ingress cert-manager ca cert rebuild