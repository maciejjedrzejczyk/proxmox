#!/bin/sh

export QCOW_IMAGE=focal-server-cloudimg-amd64-current.img
export CLIENT_CERT=id_rsa.pub
export TEMPLATE_ID=9000
export TEMPLATE_USERNAME=mj
export TEMPLATE_PASSWORD=password
export VM_ID=100
export IMAGE_URL=https://cloud-images.ubuntu.com/focal/current
export IMAGE_NAME=focal-server-cloudimg-amd64.img
export IMAGE_PREP_NAME=focal-server-cloudimg-amd64-current.img
export VM1_NAME=hlfdev
export VM1_IP=192.168.0.9/24

# Destroy previous template
qm destroy $TEMPLATE_ID

# Delete previous image
#rm focal-server-cloudimg-amd64.img
rm $IMAGE_NAME

# Download a new image
wget -nc $IMAGE_URL/$IMAGE_NAME
cp $IMAGE_NAME $IMAGE_PREP_NAME

# Resize source image
qemu-img resize $QCOW_IMAGE +10G

# Customize downloaded image
virt-customize -a $QCOW_IMAGE --install qemu-guest-agent
virt-customize -a $QCOW_IMAGE --ssh-inject root:file:$CLIENT_CERT
virt-customize -a $QCOW_IMAGE --root-password "$TEMPLATE_PASSWORD"
virt-customize -a $QCOW_IMAGE --hostname template
#virt-customize -a $QCOW_IMAGE --run-command "apt-get update && apt-get upgrade -y"
virt-customize -a $QCOW_IMAGE --run-command "sudo apt install resolvconf -y"
virt-customize -a $QCOW_IMAGE --run-command "adduser $TEMPLATE_USERNAME --gecos 'First Last,RoomNumber,WorkPhone,HomePhone'"
virt-customize -a $QCOW_IMAGE --run-command "echo "$TEMPLATE_USERNAME:$TEMPLATE_PASSWORD" | sudo chpasswd"
virt-customize -a $QCOW_IMAGE --run-command "usermod -aG sudo $TEMPLATE_USERNAME"
virt-customize -a $QCOW_IMAGE --ssh-inject $TEMPLATE_USERNAME:file:$CLIENT_CERT
virt-customize -a $QCOW_IMAGE --copy-in docker.sh:/home/$TEMPLATE_USERNAME
virt-customize -a $QCOW_IMAGE --run-command "chmod +x /home/$TEMPLATE_USERNAME/docker.sh"
virt-customize -a $QCOW_IMAGE --run-command "/home/$TEMPLATE_USERNAME/docker.sh"
virt-customize -a $QCOW_IMAGE --copy-in global.sh:/home/$TEMPLATE_USERNAME
virt-customize -a $QCOW_IMAGE --run-command "chmod +x /home/$TEMPLATE_USERNAME/global.sh"
virt-customize -a $QCOW_IMAGE --run-command "/home/$TEMPLATE_USERNAME/global.sh"
virt-customize -a $QCOW_IMAGE --run-command "usermod -aG docker $TEMPLATE_USERNAME"

# # Create a template
qm create $TEMPLATE_ID --name "ubuntu-2004-cloudinit-template" --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk $TEMPLATE_ID $QCOW_IMAGE SSD
qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 SSD:vm-9000-disk-0
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm set $TEMPLATE_ID --ide2 SSD:cloudinit
qm set $TEMPLATE_ID --serial0 socket --vga serial0
qm set $TEMPLATE_ID --agent 1
qm template $TEMPLATE_ID

qm stop $VM_ID && qm destroy $VM_ID

qm clone $TEMPLATE_ID $VM1_ID --name $VM1_NAME
#qm set $VM_ID --sshkey ~/.ssh/id_rsa.pub
qm set $VM1_ID --ipconfig0 ip=$VM1_IP,gw=192.168.0.1
qm set $VM1_ID --vcpus 2
qm set $VM1_ID --sockets 2
qm set $VM1_ID --memory 16384
qm resize $VM1_ID scsi0 +40G
qm start $VM1_ID