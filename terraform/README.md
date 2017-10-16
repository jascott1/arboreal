# Using Terraform  

## With OpenStack

1. `cd terraform/openstack`
1. Edit tfvars and adapt settings for your environment (image resources, private key, network pool etc.)
2. Source the openrc_v3.sh file from your OpenStack with `. openrc_v3.sh`
3. Execute `terraform apply` to create servers and Ansible inventory file.
4. After the VMs are created, execute the following command to install Kubernetes:
   
```
   ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i k8s-inventory ../../deploy-k8s.yml
```






