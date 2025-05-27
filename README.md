📘 README.md – CI/CD Pipeline with Terraform, EKS, Kubernetes, and ArgoCD
🚀 CI/CD Infrastructure with GitOps on AWS (EKS + Terraform + ArgoCD)
This project provisions a complete CI/CD infrastructure pipeline on AWS using Terraform, Kubernetes, and ArgoCD, with GitOps principles. The application deployed is a basic NGINX web server using a Kubernetes Deployment and Service.

🎯 Objectives
Provision AWS EKS Cluster using Terraform

Deploy an NGINX application using GitOps (ArgoCD)

Use ArgoCD to automate deployment from a GitHub repository

Expose ArgoCD and the NGINX application

🧱 Project Structure
bash
Copy
Edit
.
├── terraform/               # Terraform code for provisioning EKS
├── manifests/               # Kubernetes manifests (Deployment + Service)
├── argocd/                  # ArgoCD Application definition
└── README.md                # This file
✅ Step-by-Step Execution
1️⃣ Infrastructure Provisioning with Terraform
Location: terraform/

We used the terraform-aws-modules/eks/aws module to provision:

VPC

EKS Cluster

IAM roles and Node Groups

Cluster endpoint with public access enabled

❗ The EKS cluster endpoint is public, so we can connect from our local machine for management and ArgoCD setup.

🛠 Commands Executed:
bash
Copy
Edit
cd terraform
terraform init
terraform apply -auto-approve
After apply, we configured kubectl:

bash
Copy
Edit
aws eks --region us-east-1 update-kubeconfig --name devops-eks-cluster
kubectl get nodes
2️⃣ Kubernetes Manifests for NGINX
Location: manifests/

We created the following files:

nginx-deployment.yaml: Defines a Deployment of NGINX pods

nginx-service.yaml: Exposes NGINX via NodePort

These are committed to GitHub so that ArgoCD can sync and deploy them automatically using GitOps.

3️⃣ Install and Expose ArgoCD
Commands Executed:

bash
Copy
Edit
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
Then we exposed the ArgoCD UI via a LoadBalancer:

bash
Copy
Edit
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n argocd
4️⃣ Access ArgoCD UI
Visit the LoadBalancer URL on port 443

Default login:
Username: admin
Password (retrieve using):

bash
Copy
Edit
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
5️⃣ GitOps Setup – ArgoCD Application
Location: argocd/nginx-app.yaml

We created an ArgoCD Application resource pointing to our GitHub repository:

yaml
Copy
Edit
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-app
  namespace: argocd
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/<your-username>/<your-repo-name>
    targetRevision: HEAD
    path: manifests
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
This tells ArgoCD to continuously monitor and sync the NGINX manifests from GitHub to EKS.

Apply the Application:

bash
Copy
Edit
kubectl apply -f argocd/nginx-app.yaml
6️⃣ Access the NGINX Application
We used a NodePort service to expose NGINX.

Get the NodePort:

bash
Copy
Edit
kubectl get svc
Get the Node External IP:

bash
Copy
Edit
kubectl get nodes -o wide
Then access in browser:
http://<NodeExternalIP>:<NodePort>

🧠 Key Concepts Used
Infrastructure as Code (IaC): EKS and VPC created using Terraform

GitOps: ArgoCD continuously pulls manifests from GitHub

CI/CD Pipeline: Git push triggers automatic deployment to Kubernetes

Declarative Deployments: Kubernetes manifests define app state

✅ Tools Used
Tool	Purpose
Terraform	Infrastructure provisioning
AWS EKS	Managed Kubernetes cluster
kubectl	Kubernetes CLI
ArgoCD	GitOps CI/CD automation
GitHub	Source of truth for Kubernetes YAML

📌 Optional Extensions (Not Implemented Yet)
Setup Ingress Controller (e.g., AWS ALB Ingress Controller)

Use Route53 + custom domain

Set up HTTPS (TLS) for NGINX

📷 Screenshots (To Be Added)
 ArgoCD UI with NGINX app synced

 ![image](https://github.com/user-attachments/assets/f70b184e-6d84-49f7-b903-7a3f53ca7768)


 NGINX service running via LoadBalancer or NodePort

 EKS nodes visible in kubectl get nodes

🙌 Author
Ramesh Dumala
DevOps Engineer | Cloud Enthusiast
