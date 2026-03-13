
# Inception of Things

A hands-on exploration of Kubernetes infrastructure using K3s, K3d, Vagrant, and GitOps.
This repository contains three progressive projects that demonstrate **Kubernetes cluster setup, application deployment, and continuous deployment.**

### Requirements

- Vagrant
- VirtualBox
- 2GB+ available RAM

## P1: K3s and Vagrant

Sets up a multi-node Kubernetes cluster from scratch using K3s and Vagrant. This project involves:
- Creating two VMs with static IPs on a private network
- Installing K3s on the controller node `(lotrapanS at 192.168.56.110)`
- Joining a worker node `(lotrapanSW at 192.168.56.111)` to the cluster
- Automatic token sharing between nodes via Vagrant's shared folder
- Network interface detection for Flannel CNI configuration

The setup scripts handle everything: K3s installation, kubeconfig generation, and kubectl configuration for both nodes.

**Try it:**
```bash
cd p1
vagrant up
vagrant ssh lotrapanS  # or vagrant ssh lotrapanSW
kubectl get nodes -o wide

vagrant halt # to stop VMs
vagrant destroy -f # to remove VMs
```

## P2: K3s and Three Simple Applications

Deploys three web applications on a single-node K3s cluster with ingress routing. This project involves:
- Single-node K3s cluster setup
- Kubernetes Deployments and Services
- Ingress controller for host-based routing
- Replica scaling (app2 runs 3 replicas)

Applications:
- **app1**: accessible via `app1.com`
- **app2**: accessible via `app2.com` (3 replicas)
- **app3**: default route (accessible via IP)

**Try it:**
```bash
cd p2
vagrant up

# Add to your /etc/hosts:
192.168.56.110 app1.com app2.com

# Test with curl:
curl -H "Host: app1.com" 192.168.56.110
curl -H "Host: app2.com" 192.168.56.110
curl 192.168.56.110  # app3 (default)
```

All applications use the same container image (`paulbouwer/hello-kubernetes:1.10`) but are routed differently based on the hostname.

## P3: K3d and Argo CD

GitOps continuous deployment pipeline using K3d and Argo CD — no Vagrant required. The cluster runs entirely inside Docker containers on the host machine.

**Architecture:**
- K3d cluster with two namespaces: `argocd` and `dev`
- Argo CD monitors a public GitHub repository and auto-deploys changes
- `wil42/playground` (v1/v2) deployed in the `dev` namespace via a NodePort service
- Updating the image tag in the repo triggers an automatic rollout

**Ports:**
- `localhost:8888` → wil-playground app (nodePort 30420)
- `localhost:8080` → Argo CD UI (nodePort 30443, HTTPS)

**Try it:**
```bash
cd p3

bash scripts/launch.sh

# Test the app
# - go to http://localhost:8888/ and put the credentials given during setup.sh

# or test from CLI:
curl http://localhost:8888/
# {"status":"ok", "message": "v1"}

# Update version: edit p3/app/wil.yaml, change v1 → v2, push to GitHub
# Argo CD auto-syncs within ~3 minutes, then:
curl http://localhost:8888/
# {"status":"ok", "message": "v2"}

# per eliminare cluster
k3d cluster delete lotrapanS
```

**Useful Argo CD commands:**
```bash
argocd login localhost:8080 --insecure   # authenticate
argocd app list                          # list applications
argocd app get wil-playground            # detailed status
argocd app sync wil-playground           # force manual sync
```

**Scripts:**
- `install.sh` — installs Docker, kubectl, K3d CLI, Argo CD CLI
- `setup.sh` — creates the K3d cluster, installs Argo CD, exposes it via NodePort
- `deploy.sh` — registers the GitHub repo in Argo CD and creates the app with auto-sync

---

## K3s vs K3d

| | K3s | K3d |
|---|---|---|
| **What it is** | Lightweight Kubernetes | Wrapper that runs K3s inside Docker |
| **Runs on** | VM / bare metal | Docker containers |
| **Used in** | P1 and P2 (Vagrant VMs) | P3 (directly on the host) |

K3d simulates cluster nodes as Docker containers — no Vagrant or separate VMs needed.
