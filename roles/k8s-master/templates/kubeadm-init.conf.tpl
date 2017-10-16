kind: MasterConfiguration
apiVersion: kubeadm.k8s.io/v1alpha1
cloudProvider: {{ cloud_provider }}
api:
  advertiseAddress: {{ api_advertise_ip }}
networking:
  serviceSubnet: {{ service_cidr }}
  podSubnet: {{ pod_cidr }}
kubernetesVersion: v{{ kubernetes_version }}
token: {{ token }}
