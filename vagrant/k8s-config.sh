#!/bin/bash
if [ $# != 1 ]; then
  echo "Retrieve remote <host>/etc/kubernetes/admin.conf as local ~/.kube/config"
  echo "Usage: k8s-config.sh <hostname or IP>"
  echo "Exmaple: ./k8s-config.sh node-0"
  exit 1
fi 
echo "Copying $1/etc/kubernetes/admin.conf to local ~/.kube/config..."
vagrant ssh $1 -c "sudo cat /etc/kubernetes/admin.conf" > $HOME/.kube/config
