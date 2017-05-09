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

provider "aws" {}

/*resource "aws_vpc" "k8s-vpc" {
  cidr_block = "172.16.0.0/16"
  tags {
    Name = "k8s-vpc"
  }
}

resource "aws_subnet" "k8s-subnet" {
  vpc_id = "${aws_vpc.k8s-vpc.id}"
  cidr_block = "172.16.10.0/24"
  availability_zone = "us-west-2a"
  tags {
    Name = "k8s-subnet"
  }
}*/
//variable "vpc_id" {
//  default = "vpc-b5f3cfd2"
//}
//
//data "aws_vpc" "selected" {
//  id = "${var.vpc_id}"
//}

# Create a VPC to launch our instances into
resource "aws_vpc" "k8s" {
  cidr_block           = "172.1.0.0/16"
  enable_dns_hostnames = true


}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "k8s" {
  vpc_id = "${aws_vpc.k8s.id}"

}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.k8s.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.k8s.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "k8s" {
  count                   = "1"
  vpc_id                  = "${aws_vpc.k8s.id}"
  availability_zone       = "us-west-2a"
  cidr_block              = "${aws_vpc.k8s.cidr_block}"
  map_public_ip_on_launch = true

}

//resource "aws_subnet" "k8s-subnet" {
//  vpc_id            = "${data.aws_vpc.selected.id}"
//  availability_zone = "us-west-2a"
//  cidr_block        = "${cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 1)}"
//  map_public_ip_on_launch = true
//
//}

//resource "aws_network_interface" "eth0" {
//  subnet_id = "${aws_subnet.k8s.id}"
//  #private_ips = ["172.16.10.100"]
//  tags {
//    Name = "primary_network_interface"
//  }
//}
variable "ubuntu_ami_id"{
  default = "ami-efd0428f"
}
variable "centos_ami_id"{
  default = "ami-571e3c30"
}
resource "null_resource" "ref" {
  triggers = {
    image-id = "${var.os == "ubuntu" ?  var.ubuntu_ami_id : var.centos_ami_id}"
  }
}

//data "aws_ami" "ubuntu" {
//  most_recent = true
//
//  filter {
//    name   = "name"
//    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
//  }
//
//  filter {
//    name   = "virtualization-type"
//    values = ["hvm"]
//  }
//
//  owners = ["099720109477"] # Canonical
//}
//
//data "aws_ami" "centos" {
//  most_recent = true
//
//  filter {
//    name   = "image-id"
//    values = ["ami-571e3c30"]
//  }
//
//  filter {
//    name   = "virtualization-type"
//    values = ["hvm"]
//  }
//
//
//}

resource "aws_instance" "k8s-master" {
  ami           = "${null_resource.ref.triggers.image-id}"
  instance_type = "t2.large"

  tags {
    Name = "jascott1-dev-ubuntu"
  }
  root_block_device {
    volume_size = 20
  }
//  network_interface {
//    network_interface_id = "${aws_network_interface.eth0.id}"
//    device_index = 0
//  }
  subnet_id              = "${aws_subnet.k8s.id}"
  key_name = "jascott1-aws"
}
//resource "aws_eip" "lb" {
//  instance = "${aws_instance.k8s-master.id}"
//  vpc      = true
//}
//data "aws_eip" "proxy_ip" {
//
//}

resource aws_eip_association "proxy_eip" {
  instance_id   = "${aws_instance.k8s-master.id}"
  #allocation_id = "${data.aws_eip.proxy_ip.id}"
  allocation_id = "eipalloc-4991f873"
}
/*
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
resource "openstack_compute_floatingip_v2" "master-ip" {
  pool = "${var.floating-ip-pool}"
}

resource "openstack_compute_instance_v2" "k8s-master" {
  name = "${var.prefix}-k8s-master"
  #image_name = "${var.image-name}"
  image_id = "${null_resource.ref.triggers.image-id}"
  flavor_name = "${var.image-flavor}"
  key_pair = "${var.key-pair}"
  security_groups = ["${split(",", var.security-groups)}"]
  */
/*network {
    name = "${var.internal-ip-pool}"
  }*//*

  network {
    uuid = "${openstack_networking_network_v2.network-control.id}"
  }
  provisioner "remote-exec" {
    connection {
      agent = false
      timeout = "10m"
      host = "192.168.202.2"
      user = "ubuntu"
      private_key = "/Users/jascott1/.ssh/jascott1-sc.pem"
      # Bastion details
      bastion_host = "8.44.40.57"
      bastion_user = "test"
      bastion_private_key = "/Users/jascott1/.ssh/santa"
    }
  }
  //user_data = "sed -i 's/localhost/localhost jascott1-k8s-master/' /etc/hosts"
}

# Associate floating IP to first controller
resource "openstack_compute_floatingip_associate_v2" "controller-fip" {
  floating_ip = "${openstack_compute_floatingip_v2.master-ip.address}"
  instance_id = "${openstack_compute_instance_v2.k8s-master.0.id}"
  fixed_ip = "${openstack_compute_instance_v2.k8s-master.0.network.0.fixed_ip_v4}"
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
  //floating_ip = "${element(openstack_compute_floatingip_v2.node-ip.*.address, count.index)}"
}*/
