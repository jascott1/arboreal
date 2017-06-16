resource "null_resource" "ansible-provision" {
  depends_on = ["openstack_compute_instance_v2.k8s-master","openstack_compute_instance_v2.k8s-node"]

  ##Create Masters Inventory
  provisioner "local-exec" {
    command =  "echo \"[kube-masters]\n${openstack_compute_floatingip_v2.master-fip.address} ansible_ssh_host=${openstack_compute_floatingip_v2.master-fip.address}\" > k8s-inventory"
  }
  ##Create ETCD Inventory

  ##Create Nodes Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[kube-workers]\" >> k8s-inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s-node.*.access_ip_v4, openstack_compute_instance_v2.k8s-node.*.access_ip_v4))}\" >> k8s-inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:children]\nkube-workers\nkube-masters\" >> k8s-inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:vars]\nansible_user=ubuntu\nansible_ssh_private_key_file=${var.private-key-file}\nansible_python_interpreter=/usr/bin/python2.7\" >> k8s-inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"\n[kube-control:children]\nkube-masters\" >> k8s-inventory"
  }

}
