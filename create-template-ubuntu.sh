#!/bin/sh


# OS Images
export QCOW_IMAGE=jammy-server-cloudimg-amd64-current.img
export IMAGE_URL=https://cloud-images.ubuntu.com/jammy/current
export IMAGE_NAME=jammy-server-cloudimg-amd64.img
export IMAGE_PREP_NAME=jammy-server-cloudimg-amd64-current.img

# Setting up Template variables
export TEMPLATE_ID=9000
export TEMPLATE_NAME=ubuntu-2204lts-template
export PROXMOX_CLIENT_CERT=/root/.ssh/id_rsa.pub
export MACBOOK_CLIENT_CERT=/root/proxmox/id_rsa.pub
export CLOUDCFG=cloud.cfg
export TEMPLATE_USERNAME=mj
export TEMPLATE_PASSWORD=password
# export SCRIPT_DOCKER=install-docker-ubuntu.sh
# export SCRIPT_ENV=install-global-env.sh
export TEMPLATE_VCPUS=2
export TEMPLATE_MEMORY=2048

# Setting up Proxmox Infrastructure variables
export PROXMOX_INFRA_STORAGE=pool

# Setting up VM variables
export VM1_ID=100
export VM1_NAME=minifabric
export VM1_IP=192.168.1.110/24
export VM1_VCPUS=2
export VM1_SOCKETS=2
export VM1_MEMORY=6092
export VM1_STORAGE=40G

# Destroy previous template
qm stop $VM1_ID && qm destroy $VM1_ID
qm destroy $TEMPLATE_ID

# Delete previous image
#rm jammy-server-cloudimg-amd64.img
rm $IMAGE_PREP_NAME

# Download a new image
wget -nc $IMAGE_URL/$IMAGE_NAME
cp $IMAGE_NAME $IMAGE_PREP_NAME

# Resize source image
qemu-img resize $QCOW_IMAGE +10G

# Customize downloaded image
virt-customize -a $QCOW_IMAGE --install qemu-guest-agent
virt-customize -a $QCOW_IMAGE --copy-in $CLOUDCFG:/etc/cloud
# virt-customize -a $QCOW_IMAGE --ssh-inject root:file:$PROXMOX_CLIENT_CERT
# virt-customize -a $QCOW_IMAGE --ssh-inject root:file:$MACBOOK_CLIENT_CERT
# virt-customize -a $QCOW_IMAGE --root-password "$TEMPLATE_PASSWORD"
# virt-customize -a $QCOW_IMAGE --hostname template
#virt-customize -a $QCOW_IMAGE --run-command "apt-get update && apt-get upgrade -y"
# virt-customize -a $QCOW_IMAGE --run-command "sudo apt install resolvconf -y"
virt-customize -a $QCOW_IMAGE --run-command "adduser $TEMPLATE_USERNAME --gecos 'First Last,RoomNumber,WorkPhone,HomePhone'"
virt-customize -a $QCOW_IMAGE --run-command "echo "$TEMPLATE_USERNAME:$TEMPLATE_PASSWORD" | sudo chpasswd"
virt-customize -a $QCOW_IMAGE --run-command "usermod -aG sudo $TEMPLATE_USERNAME"
virt-customize -a $QCOW_IMAGE --ssh-inject $TEMPLATE_USERNAME:file:$PROXMOX_CLIENT_CERT
virt-customize -a $QCOW_IMAGE --ssh-inject $TEMPLATE_USERNAME:file:$MACBOOK_CLIENT_CERT
# virt-customize -a $QCOW_IMAGE --copy-in $SCRIPT_DOCKER:/home/$TEMPLATE_USERNAME
# virt-customize -a $QCOW_IMAGE --run-command "chmod +x /home/$TEMPLATE_USERNAME/$SCRIPT_DOCKER"
# virt-customize -a $QCOW_IMAGE --run-command "/home/$TEMPLATE_USERNAME/$SCRIPT_DOCKER"
# virt-customize -a $QCOW_IMAGE --copy-in $SCRIPT_ENV:/home/$TEMPLATE_USERNAME
# virt-customize -a $QCOW_IMAGE --run-command "chmod +x /home/$TEMPLATE_USERNAME/$SCRIPT_ENV"
# virt-customize -a $QCOW_IMAGE --run-command "/home/$TEMPLATE_USERNAME/$SCRIPT_ENV"
virt-customize -a $QCOW_IMAGE --run-command "usermod -aG docker $TEMPLATE_USERNAME"

# # Create a template
qm create $TEMPLATE_ID --name "$TEMPLATE_NAME" --memory $TEMPLATE_MEMORY --cores $TEMPLATE_VCPUS --net0 virtio,bridge=vmbr0
qm importdisk $TEMPLATE_ID $QCOW_IMAGE $PROXMOX_INFRA_STORAGE
qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 $PROXMOX_INFRA_STORAGE:vm-$TEMPLATE_ID-disk-0
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm set $TEMPLATE_ID --ide2 $PROXMOX_INFRA_STORAGE:cloudinit
qm set $TEMPLATE_ID --serial0 socket --vga serial0
qm set $TEMPLATE_ID --agent 1
qm template $TEMPLATE_ID



qm clone $TEMPLATE_ID $VM1_ID --name $VM1_NAME
#qm set $VM_ID --sshkey ~/.ssh/id_rsa.pub
qm set $VM1_ID --ipconfig0 ip=$VM1_IP,gw=192.168.1.1
qm set $VM1_ID --vcpus $VM1_VCPUS
qm set $VM1_ID --sockets $VM1_SOCKETS
qm set $VM1_ID --memory $VM1_MEMORY
qm resize $VM1_ID scsi0 $VM1_STORAGE
qm start $VM1_ID
sleep 120 && qm snapshot $VM1_ID cleanstate