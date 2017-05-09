resource "null_resource" "ansible-provision" {
  depends_on = ["aws_instance.k8s-master"]

  ##Create Masters Inventory
  /*provisioner "local-exec" {
    command =  "echo \"[kube-masters]\n${openstack_compute_instance_v2.k8s-master.name} ansible_ssh_host=${openstack_compute_floatingip_v2.master-ip.address}\" > k8s-inventory"
  }*/
  provisioner "local-exec" {
    command =  "echo \"[kube-masters]\n${aws_instance.k8s-master.public_ip} ansible_ssh_host=${aws_instance.k8s-master.public_ip}\" > k8s-inventory"
  }
  ##Create ETCD Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[etcd]\n${aws_instance.k8s-master.public_ip} ansible_ssh_host=${aws_instance.k8s-master.public_ip}\" >> k8s-inventory"
  }

  ##Create Nodes Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[kube-workers]\" >> k8s-inventory"
  }
  //  provisioner "local-exec" {
  //    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s-node.*.name, openstack_compute_floatingip_v2.node-ip.*.address))}\" >> k8s-inventory"
  //  }
//  provisioner "local-exec" {
//    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s-node.*.name, openstack_compute_instance_v2.k8s-node.*.access_ip_v4))}\" >> k8s-inventory"
//  }
//  provisioner "local-exec" {
//    command =  "echo \"\n[k8s-cluster:children]\nkube-workers\nkube-masters\" >> k8s-inventory"
//  }
  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:vars]\nansible_user=ubuntu\nansible_ssh_private_key_file=${var.private-key-file}\" >> k8s-inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"\n[kube-control]\n${aws_instance.k8s-master.public_ip}\" >> k8s-inventory"
  }

}