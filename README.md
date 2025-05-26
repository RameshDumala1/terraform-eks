# terraform-eks

# DevOps CI/CD Pipeline on AWS with Terraform, EKS, ArgoCD, Ingress

## 🚀 Overview
This project demonstrates a complete CI/CD pipeline using:

- **Terraform** for provisioning AWS infrastructure
- **Amazon EKS** to run Kubernetes workloads
- **ArgoCD** for GitOps-based continuous delivery
- **Ingress + DNS** for exposing applications via custom domains

---

## 📦 Folder Structure
```
DevOps-CI-CD/
├── terraform/         # Terraform IaC for EKS Cluster
├── manifests/         # Kubernetes YAML files (NGINX app)
├── argocd/            # ArgoCD Application config
└── README.md          # Project documentation
```

---

## 1️⃣ Provision AWS EKS Cluster with Terraform

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.3 installed

### Steps
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

This creates:
- VPC and subnets (or uses provided ones)
- EKS Cluster
- Node groups
- IAM roles

### Access Cluster
```bash
aws eks --region <region> update-kubeconfig --name <cluster_name>
kubectl get nodes
```

---

## 2️⃣ Deploy NGINX to EKS

### Apply Manifests
```bash
kubectl apply -f manifests/nginx-deployment.yaml
kubectl apply -f manifests/nginx-service.yaml
```

Check:
```bash
kubectl get pods
kubectl get svc
```

---

## 3️⃣ Install ArgoCD

### Install to `argocd` Namespace
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Access ArgoCD UI
Port-forward:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Access via: [https://localhost:8080](https://localhost:8080)

### Login
```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```
Username: `admin`, Password: `<above>`

### Deploy App via ArgoCD
```bash
kubectl apply -f argocd/nginx-app.yaml -n argocd
```

---

## 4️⃣ Access NGINX App

### Option 1: Port-forward
```bash
kubectl port-forward svc/nginx-service 8081:80
# Access http://localhost:8081
```

### Option 2: LoadBalancer (if service type is LoadBalancer)
```bash
kubectl get svc nginx-service
```

---

## 5️⃣ (Optional Bonus) Ingress + DNS Setup

### Step 1: Install Ingress Controller
For example, AWS ALB Ingress Controller or NGINX Ingress Controller:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/aws/deploy.yaml
```

### Step 2: Create Ingress Resource
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: nginx.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

Apply it:
```bash
kubectl apply -f manifests/nginx-ingress.yaml
```

### Step 3: Map DNS
- Get External IP:
```bash
kubectl get ingress
```
- Point your domain (e.g., `nginx.yourdomain.com`) to the IP using Route 53 or your DNS provider.

### Verify
```bash
nslookup nginx.yourdomain.com
curl http://nginx.yourdomain.com
```

---

## ✅ Deliverables
- `terraform/` - Infrastructure setup
- `manifests/` - Kubernetes resources
- `argocd/` - ArgoCD app definition
- `README.md` - Instructions

---

## 🏁 Result
A fully functional CI/CD environment using GitOps with ArgoCD, deploying an NGINX app to AWS EKS, with optional public access via custom domain.

---

## 🔐 Notes
- Clean up using `terraform destroy` to avoid charges.
- Use free domain services like Freenom if you don’t have one.
- Consider SSL setup (e.g., cert-manager) for HTTPS access.

---

## 📧 Questions?
Feel free to open an issue or contact the DevOps team.

---
