#!/bin/sh


# OS Images
export QCOW_IMAGE=focal-server-cloudimg-amd64-current.img
export IMAGE_URL=https://cloud-images.ubuntu.com/focal/current
export IMAGE_NAME=focal-server-cloudimg-amd64.img
export IMAGE_PREP_NAME=focal-server-cloudimg-amd64-current.img

# Setting up Template variables
export TEMPLATE_ID=9000
export TEMPLATE_NAME=ubuntu-template
export CLIENT_CERT=id_rsa.pub
export TEMPLATE_USERNAME=mj
export TEMPLATE_PASSWORD=password
export SCRIPT_DOCKER=install-docker-ubuntu.sh
export SCRIPT_ENV=install-global-env.sh
export TEMPLATE_VCPUS=2
export TEMPLATE_MEMORY=2048

# Setting up Proxmox Infrastructure variables
export PROXMOX_INFRA_STORAGE=SSD

# Setting up k8s variables
export K8S_MASTER1_ID=101
export K8S_MASTER1_NAME=k3s-master-1
export K8S_MASTER1_IP=192.168.0.201/24
export K8S_MASTER1_VCPUS=2
export K8S_MASTER1_SOCKETS=1
export K8S_MASTER1_MEMORY=4096
export K8S_MASTER1_STORAGE=40G

export K8S_MASTER2_ID=102
export K8S_MASTER2_NAME=k3s-master-2
export K8S_MASTER2_IP=192.168.0.202/24
export K8S_MASTER2_VCPUS=2
export K8S_MASTER2_SOCKETS=1
export K8S_MASTER2_MEMORY=4096
export K8S_MASTER2_STORAGE=40G

export K8S_MASTER3_ID=103
export K8S_MASTER3_NAME=k3s-master-3
export K8S_MASTER3_IP=192.168.0.203/24
export K8S_MASTER3_VCPUS=2
export K8S_MASTER3_SOCKETS=1
export K8S_MASTER3_MEMORY=4096
export K8S_MASTER3_STORAGE=40G

export K8S_WORKER1_ID=201
export K8S_WORKER1_NAME=k3s-worker-1
export K8S_WORKER1_IP=192.168.0.211/24
export K8S_WORKER1_VCPUS=2
export K8S_WORKER1_SOCKETS=1
export K8S_WORKER1_MEMORY=4096
export K8S_WORKER1_STORAGE=40G

export K8S_WORKER2_ID=202
export K8S_WORKER2_NAME=k3s-worker-2
export K8S_WORKER2_IP=192.168.0.212/24
export K8S_WORKER2_VCPUS=2
export K8S_WORKER2_SOCKETS=1
export K8S_WORKER2_MEMORY=4096
export K8S_WORKER2_STORAGE=40G

export K8S_WORKER3_ID=203
export K8S_WORKER3_NAME=k3s-worker-3
export K8S_WORKER3_IP=192.168.0.213/24
export K8S_WORKER3_VCPUS=2
export K8S_WORKER3_SOCKETS=1
export K8S_WORKER3_MEMORY=4096
export K8S_WORKER3_STORAGE=40G

# Destroy previous template
qm stop $K8S_MASTER1_ID && qm destroy $K8S_MASTER1_ID
qm stop $K8S_MASTER2_ID && qm destroy $K8S_MASTER2_ID
qm stop $K8S_MASTER3_ID && qm destroy $K8S_MASTER3_ID
qm stop $K8S_WORKER1_ID && qm destroy $K8S_WORKER1_ID
qm stop $K8S_WORKER2_ID && qm destroy $K8S_WORKER2_ID
qm stop $K8S_WORKER3_ID && qm destroy $K8S_WORKER3_ID
#qm destroy $TEMPLATE_ID

# Delete previous image
#rm focal-server-cloudimg-amd64.img
#rm $IMAGE_PREP_NAME

# Download a new image
#wget -nc $IMAGE_URL/$IMAGE_NAME
#cp $IMAGE_NAME $IMAGE_PREP_NAME

# Resize source image
#qemu-img resize $QCOW_IMAGE +10G

# # Customize downloaded image
# virt-customize -a $QCOW_IMAGE --install qemu-guest-agent
# virt-customize -a $QCOW_IMAGE --ssh-inject root:file:$CLIENT_CERT
# virt-customize -a $QCOW_IMAGE --root-password "$TEMPLATE_PASSWORD"
# virt-customize -a $QCOW_IMAGE --hostname template
# #virt-customize -a $QCOW_IMAGE --run-command "apt-get update && apt-get upgrade -y"
# virt-customize -a $QCOW_IMAGE --run-command "sudo apt install resolvconf -y"
# virt-customize -a $QCOW_IMAGE --run-command "adduser $TEMPLATE_USERNAME --gecos 'First Last,RoomNumber,WorkPhone,HomePhone'"
# virt-customize -a $QCOW_IMAGE --run-command "echo "$TEMPLATE_USERNAME:$TEMPLATE_PASSWORD" | sudo chpasswd"
# virt-customize -a $QCOW_IMAGE --run-command "usermod -aG sudo $TEMPLATE_USERNAME"
# virt-customize -a $QCOW_IMAGE --ssh-inject $TEMPLATE_USERNAME:file:$CLIENT_CERT
# virt-customize -a $QCOW_IMAGE --copy-in $SCRIPT_DOCKER:/home/$TEMPLATE_USERNAME
# virt-customize -a $QCOW_IMAGE --run-command "chmod +x /home/$TEMPLATE_USERNAME/$SCRIPT_DOCKER"
# virt-customize -a $QCOW_IMAGE --run-command "/home/$TEMPLATE_USERNAME/$SCRIPT_DOCKER"
# virt-customize -a $QCOW_IMAGE --copy-in $SCRIPT_ENV:/home/$TEMPLATE_USERNAME
# virt-customize -a $QCOW_IMAGE --run-command "chmod +x /home/$TEMPLATE_USERNAME/$SCRIPT_ENV"
# virt-customize -a $QCOW_IMAGE --run-command "/home/$TEMPLATE_USERNAME/$SCRIPT_ENV"
# virt-customize -a $QCOW_IMAGE --run-command "usermod -aG docker $TEMPLATE_USERNAME"

# # Create a template
# qm create $TEMPLATE_ID --name "$TEMPLATE_NAME" --memory $TEMPLATE_MEMORY --cores $TEMPLATE_VCPUS --net0 virtio,bridge=vmbr0
# qm importdisk $TEMPLATE_ID $QCOW_IMAGE $PROXMOX_INFRA_STORAGE
# qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 $PROXMOX_INFRA_STORAGE:vm-$TEMPLATE_ID-disk-0
# qm set $TEMPLATE_ID --boot c --bootdisk scsi0
# qm set $TEMPLATE_ID --ide2 $PROXMOX_INFRA_STORAGE:cloudinit
# qm set $TEMPLATE_ID --serial0 socket --vga serial0
# qm set $TEMPLATE_ID --agent 1
# qm template $TEMPLATE_ID



qm clone $TEMPLATE_ID $K8S_MASTER1_ID --name $K8S_MASTER1_NAME
#qm set $VM_ID --sshkey ~/.ssh/id_rsa.pub
qm set $K8S_MASTER1_ID --ipconfig0 ip=$K8S_MASTER1_IP,gw=192.168.0.1
qm set $K8S_MASTER1_ID --vcpus $K8S_MASTER1_VCPUS
qm set $K8S_MASTER1_ID --sockets $K8S_MASTER1_SOCKETS
qm set $K8S_MASTER1_ID --memory $K8S_MASTER1_MEMORY
qm resize $K8S_MASTER1_ID scsi0 $K8S_MASTER1_STORAGE
qm snapshot $K8S_MASTER1_ID cleanstate
qm migrate $K8S_MASTER1_ID node02
#qm start $K8S_MASTER1_ID


qm clone $TEMPLATE_ID $K8S_MASTER2_ID --name $K8S_MASTER2_NAME
#qm set $VM_ID --sshkey ~/.ssh/id_rsa.pub
qm set $K8S_MASTER2_ID --ipconfig0 ip=$K8S_MASTER2_IP,gw=192.168.0.1
qm set $K8S_MASTER2_ID --vcpus $K8S_MASTER2_VCPUS
qm set $K8S_MASTER2_ID --sockets $K8S_MASTER2_SOCKETS
qm set $K8S_MASTER2_ID --memory $K8S_MASTER2_MEMORY
qm resize $K8S_MASTER2_ID scsi0 $K8S_MASTER2_STORAGE
qm snapshot $K8S_MASTER2_ID cleanstate
qm migrate $K8S_MASTER2_ID node02
#qm start $K8S_MASTER2_ID


qm clone $TEMPLATE_ID $K8S_MASTER3_ID --name $K8S_MASTER3_NAME
#qm set $VM_ID --sshkey ~/.ssh/id_rsa.pub
qm set $K8S_MASTER3_ID --ipconfig0 ip=$K8S_MASTER3_IP,gw=192.168.0.1
qm set $K8S_MASTER3_ID --vcpus $K8S_MASTER3_VCPUS
qm set $K8S_MASTER3_ID --sockets $K8S_MASTER3_SOCKETS
qm set $K8S_MASTER3_ID --memory $K8S_MASTER3_MEMORY
qm resize $K8S_MASTER3_ID scsi0 $K8S_MASTER3_STORAGE
qm snapshot $K8S_MASTER3_ID cleanstate
qm migrate $K8S_MASTER3_ID node02
#qm start $K8S_MASTER3_ID

qm clone $TEMPLATE_ID $K8S_WORKER1_ID --name $K8S_WORKER1_NAME
#qm set $VM_ID --sshkey ~/.ssh/id_rsa.pub
qm set $K8S_WORKER1_ID --ipconfig0 ip=$K8S_WORKER1_IP,gw=192.168.0.1
qm set $K8S_WORKER1_ID --vcpus $K8S_WORKER1_VCPUS
qm set $K8S_WORKER1_ID --sockets $K8S_WORKER1_SOCKETS
qm set $K8S_WORKER1_ID --memory $K8S_WORKER1_MEMORY
qm resize $K8S_WORKER1_ID scsi0 $K8S_WORKER1_STORAGE
qm snapshot $K8S_WORKER1_ID cleanstate
#qm migrate $K8S_WORKER1_ID node02
#qm start $K8S_WORKER1_ID

qm clone $TEMPLATE_ID $K8S_WORKER2_ID --name $K8S_WORKER2_NAME
#qm set $VM_ID --sshkey ~/.ssh/id_rsa.pub
qm set $K8S_WORKER2_ID --ipconfig0 ip=$K8S_WORKER2_IP,gw=192.168.0.1
qm set $K8S_WORKER2_ID --vcpus $K8S_WORKER2_VCPUS
qm set $K8S_WORKER2_ID --sockets $K8S_WORKER2_SOCKETS
qm set $K8S_WORKER2_ID --memory $K8S_WORKER2_MEMORY
qm resize $K8S_WORKER2_ID scsi0 $K8S_WORKER2_STORAGE
qm snapshot $K8S_WORKER2_ID cleanstate
#qm migrate $K8S_WORKER2_ID node02
#qm start $K8S_WORKER2_ID

qm clone $TEMPLATE_ID $K8S_WORKER3_ID --name $K8S_WORKER3_NAME
#qm set $VM_ID --sshkey ~/.ssh/id_rsa.pub
qm set $K8S_WORKER3_ID --ipconfig0 ip=$K8S_WORKER3_IP,gw=192.168.0.1
qm set $K8S_WORKER3_ID --vcpus $K8S_WORKER3_VCPUS
qm set $K8S_WORKER3_ID --sockets $K8S_WORKER3_SOCKETS
qm set $K8S_WORKER3_ID --memory $K8S_WORKER3_MEMORY
qm resize $K8S_WORKER3_ID scsi0 $K8S_WORKER3_STORAGE
qm snapshot $K8S_WORKER3_ID cleanstate
#qm migrate $K8S_WORKER3_ID node02
#qm start $K8S_WORKER3_ID


