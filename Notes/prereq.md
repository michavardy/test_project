## install kubectl
```bash
snap install kubectl --classic
```
## install docker
```bash
sudo apt update
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
# add docker to user group
sudo usermod -aG docker $USER
# verify
docker --version
```