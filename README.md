# Kubernetes experiment

## Introduction

This is a simple Kubernetes experiment repository. Here, I'll spin up a local Kubernetes cluster using [K3D](https://k3d.io/) and deploy a sample Fast API application to it.

## Prerequisites

- Docker installed on your machine.
- K3D installed. You can find the installation instructions [here](https://k3d.io/#installation).
- kubectl installed. You can find the installation instructions [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- Python installed on your machine.
- pip installed on your machine.

## Creating the K3D Cluster

To create a local Kubernetes cluster using K3D, run the following command:

```bash
k3d cluster create --config k3d-config.yaml
```

This command will create a K3D cluster based on the configuration specified in the `k3d-config.yaml` file.

## Using traefik as Ingress Controller

This setup uses Traefik as the Ingress controller. The Ingress resource is defined in the `app-ingress.yaml` file, which routes traffic to the Fast API application.

K3D uses K3S under the hood, which comes with Traefik pre-installed. The Ingress resource is configured to use the `traefik` ingress class.

### Applying the Ingress Resource

To apply the Ingress resource, run the following command:

```bash
kubectl apply -f app-ingress.yaml
```

## Installing cert-manager

cert-manager is used to manage TLS certificates in the cluster. In this setup, cert-manager is configured to issue a self-signed certificate for the Fast API application.

To install cert-manager in your K3D cluster, you can use the following commands:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

Verify that the cert-manager pods are running:

```bash
kubectl get pods -n cert-manager
```

## Creating a local self-signed CA

To create a local self-signed Certificate Authority (CA) for issuing TLS certificates, you can use the ClusterIssuer resource defined in the `local-ca.yaml` file.

In Kubernetes, `ClusterIssuer` is a cert-manager custom resource used to define how certificates are issued, at a **cluster-wide scope (used for any namespace)**.

It is part of **cert-manager**, not core Kubernetes.

To apply the ClusterIssuer resource, run the following command:

```bash
kubectl apply -f local-ca.yaml
```

## Creating an HTTPS Certificate for the Fast API Application

To create an HTTPS certificate for the Fast API application, you can use the Certificate resource defined in the `app-cert.yaml` file. It will use the previously created local CA to issue the certificate, and it will generate a TLS secret named `app-tls-secret` in the `default` namespace.



### Adding Host Entry

To access the application via the specified hostname, add an entry to your `/etc/hosts` file:

```bash
echo "127.0.0.1 the-app.localhost" | sudo tee -a /etc/hosts
```

### Testing it

You can test the setup by accessing the application in your web browser or using curl:

```bash
curl https://the-app.localhost --insecure
```

### Viewing the traefik Dashboard

To view the Traefik dashboard, you can port-forward the Traefik service to your local machine:

```bash
kubectl port-forward -n kube-system svc/traefik 8080:80
```

Then, open your web browser and navigate to `http://localhost:8080/dashboard/` to access the Traefik dashboard.

## Generating a self-signed certificate with cert-manager

This setup uses cert-manager to generate a self-signed TLS certificate for the Fast API application. The Certificate resource is defined in the `app-cert.yaml` file.

### Applying the Certificate Resource

To apply the Certificate resource, run the following command:

```bash
kubectl apply -f app-cert.yaml
```



