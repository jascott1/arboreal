# Using Vagrant

The Vagrantfile generates a customized version of the Ansible inventory file. 

Note: Typical setups like a MacBook Pro do not have the resources to run a  
complete installation of kolla-kubernetes. This setup should facilitate development
on subsystems such as Keystone or related projects such as Helm.

Use the following commands to create master and worker nodes:

```
cd vagrant
vagrant up

``` 

Edit the group_vars/all.yml and set the name of the management interface

```
# group_vars/all.yml
...
management_iface: enp0s8
...

```

After the VMs are created, execute the following command to install Kubernetes:

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory ../deploy-k8s.yml
```

To download the remote kubernetes config and overwrite your local .kube/config, execute the following command:

```
./k8s-config.sh node-0

```