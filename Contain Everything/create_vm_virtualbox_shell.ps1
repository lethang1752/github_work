$MACHINENAME="linux_os"
$FOLDER="E:\VirtualMachine"

#Restart adapter
Restart-NetAdapter -InterfaceDescription "VirtualBox Host-Only Ethernet Adapter"

#Create VM
VBoxManage createvm --name $MACHINENAME --ostype Oracle7_64 --register --basefolder $FOLDER
#Set memory and network
VBoxManage modifyvm $MACHINENAME --ioapic on
VBoxManage modifyvm $MACHINENAME --memory 8192 --vram 128
VBoxManage modifyvm $MACHINENAME --nic1 hostonly --host-only-adapter1="VirtualBox Host-Only Ethernet Adapter"
#Create Disk and connect Iso
VBoxManage createhd --filename $FOLDER\$MACHINENAME\${MACHINENAME}_disk.vdi --size 80000 --format VDI
VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  $FOLDER\$MACHINENAME\${MACHINENAME}_disk.vdi
VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium D:\Iso\OracleLinux-R7-U9-Server-x86_64-dvd.iso
VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

#Enable RDP
VBoxManage modifyvm $MACHINENAME --vrde on
VBoxManage modifyvm $MACHINENAME --vrdemulticon on --vrdeport 10001

#Start the VM
VBoxManage startvm $MACHINENAME

#Close
exit