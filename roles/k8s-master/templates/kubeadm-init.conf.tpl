kind: MasterConfiguration
apiVersion: kubeadm.k8s.io/v1alpha1
{% if cloud_provider %}cloudProvider: {{ cloud_provider }}{% endif %}

api:
  advertiseAddress: {{ api_advertise_ip }}
networking:
  serviceSubnet: {{ service_cidr }}
  podSubnet: {{ pod_cidr }}
kubernetesVersion: v{{ kubernetes_version }}
token: {{ token }}
