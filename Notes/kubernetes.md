## install kind
```bash
sudo snap install go --classic
mkdir ~/kind-install
cd ~/kind-install
go mod init tempmod
go get sigs.k8s.io/kind@v0.20.0
#verify
~/go/bin/kind version
sudo ln -s ~/go/bin/kind /usr/local/bin/kind
```
## Kind cmds
```bash
## spin up cluster
kind create cluster --name <cluster-name> --image kindest/node:v1.23.5
## remove cluster
kind delete cluster --name <cluster-name>
```


## create kubernetes cluster
```bash
## spin up cluster
kind create cluster --name ingress --image kindest/node:v1.23.5
# context

## verify cluster up and running
kubectl get nodes
NAME                  STATUS   ROLES                  AGE     VERSION
nginx-ingress-control-plane   Ready    control-plane,master   2m12s   v1.23.5
```

## Run a container to work in 

### run alpine linux
```bash
docker run -it --rm -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host alpine sh
docker run -it -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host alpine sh
```

### install tools
```bash
# install curl 
apk add --no-cache curl

# install kubectl 
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# install helm 

curl -o /tmp/helm.tar.gz -LO https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
tar -C /tmp/ -zxvf /tmp/helm.tar.gz
mv /tmp/linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm

```
### test cluster access
```bash
/work # kubectl get nodes
NAME                    STATUS   ROLES    AGE   VERSION
nginx-ingress-control-plane   Ready    control-plane,master   3m26s   v1.23.5
```

## NGINX Ingress Controller
### References
#### Documentation: https://docs.nginx.com/nginx-ingress-controller/
#### Documentation: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/
#### Github: https://github.com/kubernetes/ingress-nginx

### Get installation yaml
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm search repo ingress-nginx --versions
```

### check comptbility matrix
https://github.com/kubernetes/ingress-nginx/

| Ingress-NGINX version |     k8s supported version    | Alpine Version | Nginx Version | Helm Chart Version |
|:---------------------:|:----------------------------:|:--------------:|:-------------:|:------------------:|
| v1.8.2                | 1.27,1.26, 1.25, 1.24        | 3.18.2         | 1.21.6        | 4.7.*              |
| v1.8.1                | 1.27,1.26, 1.25, 1.24        | 3.18.2         | 1.21.6        | 4.7.*              |
| v1.8.0                | 1.27,1.26, 1.25, 1.24        | 3.18.0         | 1.21.6        | 4.7.*              |
| v1.7.1                | 1.27,1.26, 1.25, 1.24        | 3.17.2         | 1.21.6        | 4.6.*              |
| v1.7.0                | 1.26, 1.25, 1.24             | 3.17.2         | 1.21.6        | 4.6.*              |
| v1.6.4                | 1.26, 1.25, 1.24, 1.23       | 3.17.0         | 1.21.6        | 4.5.*              |
| v1.5.1                | 1.25, 1.24, 1.23             | 3.16.2         | 1.21.6        | 4.4.*              |
| v1.4.0                | 1.25, 1.24, 1.23, 1.22       | 3.16.2         | 1.19.10†      | 4.3.0              |
| v1.3.1                | 1.24, 1.23, 1.22, 1.21, 1.20 | 3.16.2         | 1.19.10†      | 4.2.5              |
| v1.3.0                | 1.24, 1.23, 1.22, 1.21, 1.20 | 3.16.0         | 1.19.10†      | 4.2.3              |
| v1.2.1                | 1.23, 1.22, 1.21, 1.20, 1.19 | 3.14.6         | 1.19.10†      | 4.1.4              |
| v1.1.3                | 1.23, 1.22, 1.21, 1.20, 1.19 | 3.14.4         | 1.19.10†      | 4.0.19             |
| v1.1.2                | 1.23, 1.22, 1.21, 1.20, 1.19 | 3.14.2         | 1.19.9†       | 4.0.18             |
| v1.1.1                | 1.23, 1.22, 1.21, 1.20, 1.19 | 3.14.2         | 1.19.9†       | 4.0.17             |
| v1.1.0                | 1.22, 1.21, 1.20, 1.19       | 3.14.2         | 1.19.9†       | 4.0.13             |
| v1.0.5                | 1.22, 1.21, 1.20, 1.19       | 3.14.2         | 1.19.9†       | 4.0.9              |
| v1.0.4                | 1.22, 1.21, 1.20, 1.19       | 3.14.2         | 1.19.9†       | 4.0.6              |
| v1.0.3                | 1.22, 1.21, 1.20, 1.19       | 3.14.2         | 1.19.9†       | 4.0.5              |
| v1.0.2                | 1.22, 1.21, 1.20, 1.19       | 3.14.2         | 1.19.9†       | 4.0.3              |
| v1.0.1                | 1.22, 1.21, 1.20, 1.19       | 3.14.2         | 1.19.9†       | 4.0.2              |
| v1.0.0                | 1.22, 1.21, 1.20, 1.19       | 3.13.5         | 1.20.1        | 4.0.1              |

- we select v1.5.1 because nginx-ingress-control-plane version v1.23.5  k8s supported version, Helm Chart Version 4.4.*

### create helm manifest
```bash
CHART_VERSION="4.4.0"
APP_VERSION="1.5.1"

mkdir ./kubernetes/ingress/controller/nginx/manifests/

helm template ingress-nginx ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--version ${CHART_VERSION} \
--namespace ingress-nginx \
> ./kubernetes/ingress/controller/nginx/manifests/nginx-ingress.${APP_VERSION}.yaml

```

### Deploy ingress controller
```bash
kubectl create namespace ingress-nginx
kubectl apply -f ./kubernetes/ingress/controller/nginx/manifests/nginx-ingress.${APP_VERSION}.yaml
```

### Check the installation
```bash
kubectl -n ingress-nginx get pods
```
#### Example
```bash
/work # kubectl -n ingress-nginx get pods
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-qr59j        0/1     Completed   0          62s
ingress-nginx-admission-patch-tsdmk         0/1     Completed   1          62s
ingress-nginx-controller-7d5fb757db-r8pg6   1/1     Running     0          62s
# all ingress objects will access pods th through ingress controller service
# to view service
/work # kubectl -n ingress-nginx get svc
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.183.90    <pending>     80:30756/TCP,443:30873/TCP   5m31s
ingress-nginx-controller-admission   ClusterIP      10.96.124.248   <none>        443/TCP                      5m31s
```
### Initial Test
```bash
# setup up port forwarding from 443 to svc/ingress-nginx-controller
kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 443
```
### Test Microservices A, B
```bash
# apply services
kubectl apply -f ./kubernetes/ingress/controller/nginx/features/service-a.yaml
kubectl apply -f ./kubernetes/ingress/controller/nginx/features/service-b.yaml
# check that services created pods
kubectl get pods
# port forward
kubectl port-forward svc/service-a 80
```
## Routing By Domain
### Goal
- https://public.service-a.com/ --> Ingress --> k8s service --> http://service-a/
- https://public.service-b.com/ --> Ingress --> k8s service --> http://service-b/

### Idea
- purchase a domin: public.service-a.com
- point it to your load balancer
- I can point it to my local host: 

this actually didn't work for me


## Routing By path
### Goal
- https://public.my-services.com/path-a --> Ingress --> k8s service --> http://service-a/path-a
- https://public.my-services.com/path-b --> Ingress --> k8s service --> http://service-b/path-b


### port forward
```bash
# setup up port forwarding from 443 to svc/ingress-nginx-controller
kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 443
```


