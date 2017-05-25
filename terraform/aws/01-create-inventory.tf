resource "null_resource" "ansible-provision" {
  depends_on = ["aws_instance.k8s-master"]

  ## Create masters
  provisioner "local-exec" {
    command =  "echo \"[kube-masters]\n${aws_instance.k8s-master.public_ip} ansible_ssh_host=${aws_instance.k8s-master.public_ip}\" > k8s-inventory"
  }
  ## Create etcd
  provisioner "local-exec" {
    command =  "echo \"\n[etcd]\n${aws_instance.k8s-master.public_ip} ansible_ssh_host=${aws_instance.k8s-master.public_ip}\" >> k8s-inventory"
  }
  ## Create nodes
  provisioner "local-exec" {
    command =  "echo \"\n[kube-workers]\" >> k8s-inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", aws_instance.k8s-node.*.private_ip, aws_instance.k8s-node.*.private_ip))}\" >> k8s-inventory"
  }
  ## Create cluster
  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:children]\nkube-workers\nkube-masters\" >> k8s-inventory"
  }
  ## Create vars
  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:vars]\nansible_user=${var.user}\nansible_ssh_private_key_file=${var.private-key-file}\nansible_python_interpreter=/usr/bin/python\" >> k8s-inventory"
  }
  ## Create kube-control
  provisioner "local-exec" {
    command =  "echo \"\n[kube-control]\n${aws_instance.k8s-master.public_ip}\" >> k8s-inventory"
  }

}