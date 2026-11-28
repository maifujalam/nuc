packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.1.0"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = ">= 1.1.0"
    }
  }
}

source "qemu" "k8s" {
  iso_url      = "ubuntu-26.04-minimal-cloudimg-amd64v3.img"
  iso_checksum = "sha256:f606650ca7275bb88f6cac8fd5eb3e6d711064197f667250552325e076450e7c"
  disk_image   = true
  format       = "qcow2"
  disk_size    = "20480"

  accelerator = "kvm"
  memory      = 4096
  cpus        = 2
  qemuargs = [
    ["-cpu", "host"],                 # fix 2: v3 image needs host CPU features
    ["-serial", "file:serial.log"]    # boot log, so you can see what happens
  ]

  # fix 1: cloud-init seed that sets the ubuntu password and allows password SSH
  cd_label = "cidata"
  cd_content = {
    "meta-data" = "instance-id: k8s-nuc\nlocal-hostname: k8s-nuc\n"
    "user-data" = <<-EOF
      #cloud-config
      ssh_pwauth: true
      chpasswd:
        expire: false
        users:
          - name: ubuntu
            password: ubuntu
            type: text
    EOF
  }

  communicator     = "ssh"
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "15m"
  shutdown_command = "sudo shutdown -P now"

  headless = true
  vm_name  = "k8s-nuc"
}

build {
  sources = ["source.qemu.k8s"]
  provisioner "shell" {
    script = "network.sh"
  }
  provisioner "shell" {
    script = "install-k8s.sh"
  }
  provisioner "shell" {
    script = "cleanup.sh"
  }
  post-processor "vagrant" {
    provider_override    = "libvirt"
    compression_level    = 6
    output               = "boxes/ubuntu-26.04-k8s-{{.Provider}}.box"
    keep_input_artifact  = true
  }
}