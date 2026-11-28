#!/bin/bash
set -euxo pipefail

# ---------------------------------------------------------------- versions
K8S_VERSION="1.37.1"            # kubelet / kubeadm / kubectl
CONTAINERD_VERSION="2.4.2"      # latest stable containerd
RUNC_VERSION="1.4.2"
CRICTL_VERSION="v1.37.0"        # crictl should match the k8s minor
ARCH="amd64"

K8S_MINOR="v${K8S_VERSION%.*}"  # -> v1.37

# Non-interactive apt (passed through sudo explicitly; needrestart won't prompt)
APT="sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt-get -y -o Dpkg::Options::=--force-confold"

# ---------------------------------------------------------------- base packages
$APT update
$APT full-upgrade

# containerd/runc are NOT installed from apt: Ubuntu's packages lag upstream.
$APT install \
  ansible \
  build-essential \
  unzip \
  tree \
  gpg \
  git \
  curl \
  python3-pip \
  python3-venv \
  net-tools \
  wget \
  vim \
  jq \
  nfs-common \
  chrony \
  bash-completion \
  ca-certificates \
  socat \
  conntrack \
  ebtables \
  ethtool

# ---------------------------------------------------------------- kernel modules + sysctl
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF

sudo sysctl --system

# ---------------------------------------------------------------- containerd (upstream binaries)
curl -fsSL -o /tmp/containerd.tar.gz \
  "https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-${ARCH}.tar.gz"
sudo tar -C /usr/local -xzf /tmp/containerd.tar.gz
rm -f /tmp/containerd.tar.gz

sudo mkdir -p /usr/local/lib/systemd/system
sudo curl -fsSL -o /usr/local/lib/systemd/system/containerd.service \
  "https://raw.githubusercontent.com/containerd/containerd/v${CONTAINERD_VERSION}/containerd.service"

# ---------------------------------------------------------------- runc
sudo curl -fsSL -o /tmp/runc \
  "https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.${ARCH}"
sudo install -m 0755 /tmp/runc /usr/local/sbin/runc
sudo rm -f /tmp/runc

# ---------------------------------------------------------------- containerd config (systemd cgroups)
sudo mkdir -p /etc/containerd
/usr/local/bin/containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

# containerd 2.x may omit SystemdCgroup from the default config; add it if so.
if grep -q 'SystemdCgroup' /etc/containerd/config.toml; then
  sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
else
  sudo sed -i "/runtimes\.runc\.options\]/a\            SystemdCgroup = true" /etc/containerd/config.toml
fi
grep -q 'SystemdCgroup = true' /etc/containerd/config.toml   # fail the build if not set

sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl restart containerd

# ---------------------------------------------------------------- crictl
curl -fsSL -o /tmp/crictl.tar.gz \
  "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz"
sudo tar -xzf /tmp/crictl.tar.gz -C /usr/local/bin crictl
sudo chmod 0755 /usr/local/bin/crictl
rm -f /tmp/crictl.tar.gz

cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

# ---------------------------------------------------------------- kubelet / kubeadm / kubectl
sudo mkdir -p -m 755 /etc/apt/keyrings

curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/Release.key" |
  sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/ /" |
  sudo tee /etc/apt/sources.list.d/kubernetes.list

$APT update

# Resolve the exact package revision for this patch version (e.g. 1.37.1-1.1)
K8S_PKG_VERSION="$(apt-cache madison kubeadm | awk '{print $3}' | grep "^${K8S_VERSION}-" | head -n1)"
if [ -z "${K8S_PKG_VERSION}" ]; then
  echo "kubeadm ${K8S_VERSION} not found in ${K8S_MINOR} repo" >&2
  exit 1
fi

$APT install \
  "kubelet=${K8S_PKG_VERSION}" \
  "kubeadm=${K8S_PKG_VERSION}" \
  "kubectl=${K8S_PKG_VERSION}"
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable kubelet

# ---------------------------------------------------------------- sanity checks
containerd --version
runc --version
sudo crictl info > /dev/null
sudo crictl version
kubeadm version -o short | grep -q "v${K8S_VERSION}"
kubectl version --client