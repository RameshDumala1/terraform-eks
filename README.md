# 🚀 CI/CD Infrastructure on AWS with Terraform, EKS, ArgoCD, and Ingress

This project provisions a **complete CI/CD infrastructure** on AWS using **Terraform**, **Kubernetes (EKS)**, **ArgoCD**, and **Ingress with HTTPS** using a custom domain via Route 53 and ACM.

---

## 🌟 Objectives

* Provision AWS EKS Cluster using Terraform
* Deploy an NGINX application using GitOps (ArgoCD)
* Automate deployments from GitHub repo using ArgoCD
* Expose the app via **AWS Load Balancer Ingress**
* Secure app with **HTTPS using ACM and custom domain**

---

## 🧱 Project Structure

```bash
.
├── terraform/               # Terraform code for provisioning EKS
├── manifests/               # Kubernetes manifests for NGINX
├── argocd/                  # ArgoCD Application resource
├── nginx-ingress.yaml       # Ingress resource using ALB + ACM + TLS
└── README.md
```

---

## ✅ Step-by-Step Execution

---

### 1️⃣ Provision Infrastructure Using Terraform

**Location**: `terraform/`

We used the official EKS module to create:

* VPC
* EKS Cluster (with public API endpoint)
* IAM roles and node groups

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

Configure `kubectl`:

```bash
aws eks --region us-east-1 update-kubeconfig --name devops-eks-cluster
kubectl get nodes
```

---

### 2️⃣ Deploy NGINX via Kubernetes Manifests

**Location**: `manifests/`

* `nginx-deployment.yaml`: Defines NGINX pods
* `nginx-service.yaml`: Exposes NGINX via ClusterIP (used by Ingress)

These files were committed to GitHub and automatically synced by ArgoCD.

---

### 3️⃣ Setup GitOps with ArgoCD

**Steps:**

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

Get ArgoCD initial password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Login to ArgoCD Web UI and apply the ArgoCD Application resource from `argocd/nginx-app.yaml`.

---

### 4️⃣ Install AWS Load Balancer Controller (Ingress Controller)

We:

* Enabled OIDC provider
* Created IAM policy and service account:

```bash
eksctl create iamserviceaccount \
  --cluster devops-eks-cluster \
  --region us-east-1 \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::240224986682:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve --override-existing-serviceaccounts
```

* Installed via Helm:

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=devops-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=<your-vpc-id>
```

---

### 5️⃣ Expose NGINX Using Ingress + Custom Domain

**File**: `nginx-ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:240224986682:certificate/<your-acm-cert-id>
spec:
  ingressClassName: alb
  tls:
    - hosts:
        - dumalarameshaws.info
      secretName: nginx-tls
  rules:
    - host: dumalarameshaws.info
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

Applied with:

```bash
kubectl apply -f nginx-ingress.yaml
```

---

### 6️⃣ Configure Route 53 for Domain Mapping

* Go to Route 53 > Hosted Zones > `dumalarameshaws.info`
* Create an A record:

  * Type: `A`
  * Alias: Yes
  * Alias Target: ALB DNS from `kubectl get ingress`

Verify:

```bash
curl -I https://dumalarameshaws.info
```

---

## ✅ Final Output

| Component           | Status |
| ------------------- | ------ |
| Terraform Infra     | ✅      |
| EKS Cluster         | ✅      |
| GitOps via ArgoCD   | ✅      |
| NGINX App Deployed  | ✅      |
| ALB Ingress Created | ✅      |
| HTTPS Secured       | ✅      |
| Domain Mapped       | ✅      |

---

* `kubectl get nodes`
* ArgoCD UI showing NGINX app synced
* Browser showing `https://dumalarameshaws.info`
* Route 53 record for domain
![image](https://github.com/user-attachments/assets/0d37cb8a-1970-463a-b773-86918ee9ed3a)

---

## 👨‍💼 Author

**Ramesh D**
DevOps Engineer | AWS | Kubernetes | Terraform | GitOps


 ArgoCD UI with NGINX app synced

 ![image](https://github.com/user-attachments/assets/f70b184e-6d84-49f7-b903-7a3f53ca7768)


 NGINX service running via LoadBalancer or NodePort

 ![image](https://github.com/user-attachments/assets/8e7ba680-94d4-408d-9592-7ee6e5fd8fac)

 ![image](https://github.com/user-attachments/assets/aae4068c-193e-44c3-ba9c-865bdf048bb4)



 EKS nodes visible in kubectl get nodes

 ![image](https://github.com/user-attachments/assets/a2899061-1f59-475f-b2cb-ba73935f8216)
 ![image](https://github.com/user-attachments/assets/5ede5d31-d585-412b-a170-166151076970)


🙌 Author
Ramesh Dumala
DevOps Engineer | Cloud Enthusiast
