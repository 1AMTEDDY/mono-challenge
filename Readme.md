# Mono-App - Kubernetes Deployment with Helm and GitHub Actions

**Purpose**
This repository provides **step-by-step instructions** on how to:

1. Spin up a local Kubernetes cluster using **Minikube**.
2. Containerize a simple Node.js application with **Docker**.
3. Deploy the containerized application to Kubernetes using **Helm**.
4. Automate the build and deployment process using **GitHub Actions** (including a **Reusable Workflow**).
5. Visualize the entire flow with a **draw.io (app.diagrams.net) architectural diagram**.

---

## Table of Contents

- [Mono-App - Kubernetes Deployment with Helm and GitHub Actions](#mono-app---kubernetes-deployment-with-helm-and-github-actions)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Architectural Diagram](#architectural-diagram)
  - [Prerequisites](#prerequisites)
  - [Repository Structure](#repository-structure)
  - [Step 1: Minikube Setup](#step-1-minikube-setup)

---

## Overview

This project demonstrates a **DevOps** pipeline for a Node.js app:

- **Minikube** runs Kubernetes locally for easy testing.
- **Docker** containerizes the app.
- **Helm** manages Kubernetes manifests, providing parameterization.
- **GitHub Actions** automates builds, pushes Docker images to a registry, and deploys to Kubernetes.

---

## Architectural Diagram

Below is a high-level flow of how the code gets from GitHub to Kubernetes, created with [draw.io (app.diagrams.net)](https://app.diagrams.net/).

> **Note**: If you have the `.drawio` file in your repo (e.g., `docs/architecture.drawio`), you can open it directly in draw.io or upload it to [app.diagrams.net](https://app.diagrams.net/) to view or edit.  

**Diagram**:  
```
  ┌───────────────┐       ┌─────────────────────────┐
  │               │       │                         │
  │   Developer   │       │   Docker Registry (e.g. │
  │    (GitHub)   │       │   Docker Hub)           │
  │               │       │                         │
  └───────┬───────┘       └───────┬─────────────────┘
          │ Push Code             │
          ▼                       │
  ┌───────────────────┐           │
  │ GitHub Actions    │           │
  │ (CI/CD Workflow)  │           │
  └───────┬───────────┘           │
          │ Build & Push          │
          ▼ Docker Image          │
  ┌───────────────────┐           │
  │ Helm Deployment   │           │
  │ (Reusable WF)     │           │
  └────────┬──────────┘           │
           │                      │
           ▼ ---------------------|
  ┌───────────────────┐
  │ Minikube Cluster  │
  │ (Local Kubernetes)│
  └───────────────────┘
```
- **Step 1:** Developer pushes code to GitHub.
- **Step 2:** GitHub Actions workflow triggers, builds a Docker image, and pushes it to a registry (like Docker Hub).
- **Step 3:** A reusable workflow installs/updates a Helm release on the Minikube cluster with the new image.
- **Step 4:** The application runs on Kubernetes locally via Minikube.

---

## Prerequisites

1. **Docker**  
   - Install instructions: [Docker Docs](https://docs.docker.com/get-docker/)

2. **Minikube**  
   - Install instructions: [Minikube Docs](https://minikube.sigs.k8s.io/docs/start/)

3. **kubectl**  
   - Install instructions: [Kubernetes Docs](https://kubernetes.io/docs/tasks/tools/)

4. **Helm**
   - Install instructions: [Helm Docs](https://helm.sh/docs/intro/install/)

5. **GitHub Account**
   - Ability to create repositories and configure GitHub Actions secrets.

---

## Repository Structure
```
mono-app/
├─ .github/
│   └─ workflows/
│       ├─ deploy.yml          # Main workflow triggered by pushes
│       └─ reusable-deploy.yml # Reusable workflow that handles Helm deployment
├─ chart/
│   ├─ Chart.yaml
│   ├─ values.yaml
│   └─ templates/
│       ├─ deployment.yaml
│       └─ service.yaml
├─ app.js                      # Simple Node.js Express app
├─ Dockerfile                  # Docker build instructions
└─ README.md                   # This instruction document
```
---

## Step 1: Minikube Setup

1. **Install Minikube** (see [Prerequisites](#prerequisites)).
2. **Start Minikube**:

   ```bash
   minikube start

 • This spins up a single-node Kubernetes cluster locally.

 3. Verify:

kubectl get nodes

 • You should see a node named minikube.

 Tip: If you plan to test building images locally without pushing to a remote registry, run: This points Docker commands to the Minikube Docker daemon.

Step 2: Docker Build

While GitHub Actions will ultimately build and push the Docker image, you can test locally:

 1. (Optional) Use Minikube’s Docker Daemon:

eval $(minikube docker-env)

 2. Build the Docker Image:
```
docker build -t mono-app:latest .

docker push 1amteddy/mono-app:latest
```
 • This uses the Dockerfile in the root directory.
 • If you’re using the Minikube Docker environment, you can deploy this image directly without a push to Docker Hub.

Step 3: Helm Deploy Locally (Optional)

If you want to deploy the app to your local Minikube cluster without using GitHub Actions:

 1. Install/Upgrade Helm Release:

helm upgrade --install mono-app ./chart \
  --set image.repository=mono-app \
  --set image.tag=latest

 • mono-app is the release name.
 • ./chart points to the Helm chart directory.
 • Adjust --set image.repository=mono-app if you built a local image named mono-app:latest.

 2. Check Deployment:

kubectl get pods
kubectl get svc

 • You should see a pod named something like mono-app-<hash>.

 3. Access the Application:
 kubectl port-forward svc/mono-app-service 3000:3000
navigate to http://localhost:3000

Step 4: GitHub Actions Setup

 1. Create Repository Secrets in your GitHub repo settings:
 • DOCKERHUB_USERNAME: Your Docker Hub username.
 • DOCKERHUB_TOKEN: A Docker Hub personal access token or password.
 • KUBECONFIG: Base64-encoded (or plain text) kubeconfig allowing access to your Minikube cluster
(If you’re using a remote cluster, provide that remote kubeconfig. For local-only, you might omit or store a local override.)
 1. Examine .github/workflows/deploy.yml:
 • Triggered on push to main.
 • Builds the Docker image.
 • Logs into Docker Hub.
 • Pushes the image to Docker Hub.
 • Calls reusable-deploy.yml to handle the Helm deployment.
 1. Check .github/workflows/reusable-deploy.yml:
 • Called by deploy.yml using workflow_call.
 • Checks out code (for the Helm chart).
 • Installs kubectl and Helm.
 • Configures kubeconfig from the KUBECONFIG secret.
 • Deploys/Upgrades the Helm chart with the new image repository and tag.

How to Run the CI/CD Pipeline

 1. Push Code to the main branch (or whichever branch is configured in deploy.yml):
 • The GitHub Actions pipeline will start automatically.
 • Observe build logs in the Actions tab of your GitHub repository.
 2. Build Stage:
 • The workflow checks out your code and runs docker build.
 • The Docker image is tagged and pushed to your-dockerhub-username/mono-app:latest.
 3. Deploy Stage:
 • The workflow calls reusable-deploy.yml.
 • kubectl and Helm are installed.
 • The Helm command helm upgrade --install mono-app ./chart --set image.repository=... --set image.tag=... is executed in the background.
 • Your application is deployed/updated on the Kubernetes cluster referenced by the KUBECONFIG secret.

Verification and Testing

After a successful CI/CD run:

 1. Check Pods:

kubectl get pods

 2. Check Service:

kubectl get svc

 3. Access the App:
 • If you’re using Minikube locally, run:

minikube service mono-app --url

 • If you’re using a remote cluster, retrieve the external IP or NodePort from kubectl get svc and open the address in your browser.

Cleanup

When you’re done testing:
 • Remove Local Helm Release:

helm uninstall mono-app

 • Delete Minikube Cluster (optional):

minikube delete

 • Remove Images (optional):

docker rmi mono-app:latest
docker rmi 1amteddy/mono-app:latest

Thank you for following this guide! If you have any questions, feel free to open an issue or reach out. Happy Deploying!
