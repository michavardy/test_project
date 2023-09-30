## Setup SSH server on remote
```
sudo apt install openssh-server
sudo systemctl enable ssh --now
sudo systemctl start ssh
```
C:\Users\micha.vardy\projects_mercury\snowmachine\Notes
## test ssh from inside the network
```
sudo apt install net-tools
ifconfig
10.100.102.4
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null mishmish@10.100.102.4
```

## test ssh from outside the network
```
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null mishmish@82.166.86.139
```

## ssh key
```bash
cd ~/.ssh
## usage: ssh-keygen [-q] [-a rounds] [-b bits] [-C comment] [-f output_keyfile]
##                   [-m format] [-N new_passphrase] [-O option]
##                   [-t dsa | ecdsa | ecdsa-sk | ed25519 | ed25519-sk | rsa]
##                   [-w provider] [-Z cipher]
ssh-keygen -f ~/.ssh/fertilizer -t rsa 
# copy public key to /etc/ssh
ssh-copy-id -i ~/.ssh/fertilizer.pub mishmish@82.166.86.139
ssh mishmish@82.166.86.139
```

