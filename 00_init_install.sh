# https://computingforgeeks.com/how-to-deploy-openshift-container-platform-on-kvm/

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

# Log into the bastion server 
nmcli con delete "Wired connection 1"

nmcli con add type ethernet con-name enp1s0 ifname enp1s0 \
  connection.autoconnect yes ipv4.method manual \
  ipv4.address 192.168.100.254/24 ipv4.gateway 192.168.100.1 \
  ipv4.dns 8.8.8.8
