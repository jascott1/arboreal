##Setup needed variables
variable "prefix" {
  default = "ops"
}
variable "node-count" {
  default = 3
}
variable "internal-ip-pool" {}
variable "floating-ip-pool" {}
variable "image-name" {}
variable "image-flavor" {}
variable "security-groups" {}
variable "key-pair" {}
variable "private-key-file" {
  default = "/root/.ssh/id_rsa"
}

variable "os" {
  default = "ubuntu"
}
variable "user" {
  default = "ubuntu"
}
# Image references
data "openstack_images_image_v2" "ubuntu" {
  name = "ubuntu-16.04"
  most_recent = true

}
data "openstack_images_image_v2" "centos" {
  name = "centos7"
  most_recent = true
}

# Hack to use interpolated variables. Doesnt matter here but changing a trigger causes a re-provisioning.
resource "null_resource" "ref" {
  triggers = {
    image-id = "${var.os == "ubuntu" ?  data.openstack_images_image_v2.ubuntu.id : data.openstack_images_image_v2.centos.id}"
  }
}

# Create control network
resource "openstack_networking_network_v2" "network-control" {
  name           = "${var.prefix}-control-net"
  admin_state_up = "true"
}

# Create control subnet
resource "openstack_networking_subnet_v2" "subnet-control" {
  name       = "${var.prefix}-control-subnet"
  network_id = "${openstack_networking_network_v2.network-control.id}"
  cidr       = "10.1.0.0/24"
  ip_version = 4
}

## Create a single master node and floating IP
resource "openstack_compute_floatingip_v2" "master-fip" {
  pool = "${var.floating-ip-pool}"

}
## Create a k8s master
resource "openstack_compute_instance_v2" "k8s-master" {
  name = "${var.prefix}-k8s-master"
  image_id = "${null_resource.ref.triggers.image-id}"
  flavor_name = "${var.image-flavor}"
  key_pair = "${var.key-pair}"
  security_groups = ["${split(",", var.security-groups)}"]

  network {
    name = "${var.internal-ip-pool}"
  }
  network {
    uuid = "${openstack_networking_network_v2.network-control.id}"
  }
  block_device {
    source_type           = "image"
    uuid                  = "${null_resource.ref.triggers.image-id}"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }

  block_device {
    source_type           = "blank"
    destination_type      = "volume"
    volume_size           = 20
    boot_index            = 1
    delete_on_termination = true
  }

  user_data = "#!/bin/bash\nsudo yum install -y python python-simplejson || (apt-get update && apt-get install -y python2.7 python-simplejson)"


}

# Associate floating IP to first master
resource "openstack_compute_floatingip_associate_v2" "master-fip-assoc" {
  floating_ip = "${openstack_compute_floatingip_v2.master-fip.address}"
  instance_id = "${openstack_compute_instance_v2.k8s-master.id}"
  fixed_ip = "${openstack_compute_instance_v2.k8s-master.network.0.fixed_ip_v4}"
}

##Create desired number of k8s nodes and floating IPs
//resource "openstack_compute_floatingip_v2" "node-ip" {
//  pool = "${var.floating-ip-pool}"
//  count = "${var.node-count}"
//}
//
resource "openstack_compute_instance_v2" "k8s-node" {
  count = "${var.node-count}"
  name = "${var.prefix}-k8s-node-${count.index}"
  image_name = "${var.image-name}"
  flavor_name = "${var.image-flavor}"
  key_pair = "${var.key-pair}"
  security_groups = ["${split(",", var.security-groups)}"]
  network {
    name = "${var.internal-ip-pool}"
  }
  user_data = "#!/bin/bash\nsudo yum install -y python python-simplejson || (apt-get update && apt-get install -y python2.7 python-simplejson)"
  //floating_ip = "${element(openstack_compute_floatingip_v2.node-ip.*.address, count.index)}"
}
