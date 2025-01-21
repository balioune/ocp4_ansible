# https://computingforgeeks.com/how-to-deploy-openshift-container-platform-on-kvm/

# Install KVM

sudo apt install -y cpu-checker

sudo apt install -y qemu-kvm virt-manager libvirt-daemon-system virtinst libvirt-clients bridge-utils

sudo systemctl enable --now libvirtd

sudo systemctl start libvirtd

sudo apt -y install libguestfs-tools virt-top

# Allow KVM routed network to go outside
sudo iptables -t nat -A POSTROUTING -o enp5s0f0 -j MASQUERADE

sudo virt-builder fedora-35  --format qcow2  \
--size 20G -o /var/lib/libvirt/images/ocp-bastion-server.qcow2 \
--root-password password:admin

sudo virt-install \
  --name ocp-bastion-server \
  --ram 4096 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/ocp-bastion-server.qcow2 \
  --os-type linux \
  --os-variant rhel8.0 \
  --network bridge=openshift4 \
  --graphics none \
  --serial pty \
  --console pty \
  --boot hd \
  --import

  sudo virt-install -n bootstrap \
  --description "Bootstrap Machine for Openshift 4 Cluster" \
  --ram=8192 \
  --vcpus=4 \
  --os-type=Linux \
  --os-variant=rhel8.0 \
  --noreboot \
  --disk pool=default,bus=virtio,size=50 \
  --graphics none \
  --serial pty \
  --console pty \
  --pxe \
  --network bridge=openshift4,mac=52:54:00:a4:db:5f

sudo virt-install -n master01 \
  --description "Master01 Machine for Openshift 4 Cluster" \
  --ram=16192 \
  --vcpus=4 \
  --os-type=Linux \
  --os-variant=rhel8.0 \
  --noreboot \
  --disk pool=default,bus=virtio,size=50 \
  --graphics none \
  --serial pty \
  --console pty \
  --pxe \
  --network bridge=openshift4,mac=52:54:00:8b:a1:17

sudo virt-install -n worker01 \
  --description "Worker01 Machine for Openshift 4 Cluster" \
  --ram=4192 \
  --vcpus=4 \
  --os-type=Linux \
  --os-variant=rhel8.0 \
  --noreboot \
  --disk pool=default,bus=virtio,size=50 \
  --graphics none \
  --serial pty \
  --console pty \
  --pxe \
  --network bridge=openshift4,mac=52:54:00:31:4a:39

# Log into the bastion server 
nmcli con delete "Wired connection 1"

nmcli con add type ethernet con-name enp1s0 ifname enp1s0 \
  connection.autoconnect yes ipv4.method manual \
  ipv4.address 192.168.100.254/24 ipv4.gateway 192.168.100.1 \
  ipv4.dns 8.8.8.8
