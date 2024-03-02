# Test Project

## Goal
I want to set up a kubernetes cluster in minikube, with the app called UI
External load balancing will be managed by nginx reverse proxy
minikube ingress will be controlled by internal nginx ingress controller


### main
@app.get("/hello_world")
def read_root(request: Request):
    return {"Hello": "World", "root_path": request.scope.get("root_path")}

class SPAStaticFiles(StaticFiles):
    async def get_response(self, path: str, scope):
        response = await super().get_response(path, scope)
        if response.status_code == 404:
            response = await super().get_response('.', scope)
        return response

# Mount the static files directory (built React files) to the URL path "/"
app.mount("/", SPAStaticFiles(directory="/app/frontend/build", html=True), name="static")


def start():
    """Launched with `poetry run start` at root level"""
    uvicorn.run("backend.main:app", host="0.0.0.0", port=80, reload=True)

## References
- (**docker cli reference**)[https://docs.docker.com/reference/cli/docker/]
- (**dockerfile reference**)[https://docs.docker.com/reference/dockerfile/]
- (**docker build guide**)[https://docs.docker.com/build/guide]
- (**kubectl reference**)[https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands]
- (**MiniKube**)[https://minikube.sigs.k8s.io/docs/start/]
- (**Nginx Proxy**)[https://docs.nginx.com/nginx/admin-guide/]
## Useful Commands

#### to test dockers container
```bash
docker build -t ui .
docker run -it <docker-image-id> sh
docker run -dp 80:80 <docker-image-id>
```

#### Setup Kubernetes
1. install minikube
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
2. start cluster
`minikube start`

3. install kubectl or use minikube kubectl 
```bash
alias kubectl="minikube kubectl --"
```

4. access dashboard
`minikube dashboard`

#### Ingress Deployment / Service
1. enable ingress
```bash
minikube addons enable ingress
```

2. create manifest.yaml
```yaml
kind: Pod
apiVersion: v1
metadata:
  name: ui-app
  labels:
    app: ui
spec:
  containers:
    - name: ui-app
      image: michav1/ui:0.1.11
---
kind: Service
apiVersion: v1
metadata:
  name: ui-service
spec:
  selector:
    app: ui
  ports:
    - port: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ui-ingress
spec:
  rules:
    - http:
        paths:
          - pathType: Prefix
            path: /ui
            backend:
              service:
                name: ui-service
                port:
                  number: 8080
---
```

3. apply manifest
```bash
kubectl apply -f ./manifest.yaml
```

4. wait for ingress address
```bash
kubectl get ingress
NAME              CLASS   HOSTS   ADDRESS        PORTS   AGE
example-ingress   nginx   *       192.168.49.2   80      3d4h
```
- note:
    - our ingress address was provided by minikube

#### To Setup Nginx Load Balancer

- make sure that there is port forwarding from the router to the load balancer port for example

|protocol|external_host |internal_host|external_port|internal_port|Internal_Interface|
|--------|--------------|-------------|-------------|-------------|------------------|
|    TCP | 82.166.86.139| 1.100.102.4 | 3000        | 3000        | IP_BR_LAN        |

1. install nginx (if its not already installed)
```bash
sudo apt update
sudo apt install nginx # install nginx
sudo ufw allow 'Nginx Full' # adjust firewall
systemctl status nginx # check status
```

2. edit nginx.conf: /etc/nginx/nginx.conf

```bash
sudo vim  /etc/nginx/nginx.conf
```
2.1 copy paste this in

```bash
events {}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    server {
        listen 3000;
        location /ui {
            proxy_pass http://192.168.49.2/ui/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;
        }
    }
}
```

2. reload nginx service
```bash
sudo systemctl reload nginx
```

3. test service: (in browser)
`http://82.166.86.139:3000/ui`


#### Troubleshoot
##### Nginx Logs
```bash
sudo tail -f /var/log/nginx/access.log
```

##### Pod Logs
```bash
# Find all pod names
mishmish@orchard ~/projects/test_project/K8s $ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
balanced-dc9897bb7-sks5s          1/1     Running   0          3d6h
balanced2-f55647f45-dfg7t         1/1     Running   0          3d6h
bar-app                           1/1     Running   0          3d5h
foo-app                           1/1     Running   0          3d5h
hello-minikube-7f54cff968-xpftm   1/1     Running   0          3d16h
ui-app                            1/1     Running   0          45m

# get logs of specific pod
mishmish@orchard ~/projects/test_project/K8s $ kubectl logs ui-app
INFO:     Will watch for changes in these directories: ['/app/backend']
INFO:     Uvicorn running on http://0.0.0.0:80 (Press CTRL+C to quit)
INFO:     Started reloader process [1] using WatchFiles
INFO:     Started server process [9]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

##### Ingress Logs
```bash
# get all namespaces
mishmish@orchard ~/projects/test_project/K8s $ kubectl get namespaces
NAME                   STATUS   AGE
default                Active   3d16h
ingress-nginx          Active   3d6h
kube-node-lease        Active   3d16h
kube-public            Active   3d16h
kube-system            Active   3d16h
kubernetes-dashboard   Active   3d16h

# Find all pod names in ingress-nginx namespace
mishmish@orchard ~/projects/test_project/K8s $ kubectl get pods -n ingress-nginx 
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-bqct7        0/1     Completed   0          3d6h
ingress-nginx-admission-patch-lg849         0/1     Completed   0          3d6h
ingress-nginx-controller-7c6974c4d8-dqgr4   1/1     Running     0          3d6h

# get logs of nginx-controller pod
kubectl logs -f ingress-nginx-controller-7c6974c4d8-dqgr4 -n ingress-nginx 
```
#### exec into pod
```bash
kubectl exec -it ui-app -- /bin/sh
```

## Future Plans for Automation