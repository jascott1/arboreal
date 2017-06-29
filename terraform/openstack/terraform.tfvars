# general
prefix="jascott1"
node-count="3"

# network
internal-ip-pool="private-net-justinascott"
floating-ip-pool="public"

# server specs
os="ubuntu" # ubuntu or centos
image-flavor="m1.medium"

# security
security-groups="default"
key-pair="jascott1-jfc"
private-key-file="/Users/jascott1/.ssh/jascott1-jfc"

# image resources
ubuntu-image="xenial-server-cloudimg-amd64"
centos-image="centos-7-x86_64-genericcloud"
