#!/usr/bin/env bash

ALLOCATED_RAM="24576" # MiB

args=(
  -enable-kvm
  -machine q35,vmport=off,sata=off,usb=off
  -m "$ALLOCATED_RAM"
  -cpu host,kvm=off,vendor=GenuineIntel,+kvm_pv_unhalt,+kvm_pv_eoi,+hypervisor,+invtsc
  -smp 12,cores=1,sockets=6,threads=2,maxcpus=12
  -no-hpet
  -rtc base=utc,clock=vm
  
  -vga none 
  -nographic
  
  # bios
  -smbios type=2
  -drive if=pflash,format=raw,readonly=on,file="/usr/share/OVMF/OVMF_CODE.fd"
  -drive if=pflash,format=raw,file="./ovmf/macOS-igpu_VARS.fd"
  
  # drives
  -device ich9-ahci,id=sata,bus=pcie.0,addr=0x01
  -device ide-hd,bus=sata.0,drive=OpenCore
  -device ide-hd,bus=sata.1,drive=MacOS
  -drive id=OpenCore,if=none,format=qcow2,file="./images/OpenCore/build/igpu.qcow2"
  -drive id=MacOS,if=none,format=qcow2,file="./images/monterey_hdd_ng.img"
  
  # igpu
  -device vfio-pci,host=00:02.0,bus=pcie.0,addr=0x02,rombar=0,x-igd-opregion=on,x-igd-gms=1
  
  # heci
  -device vfio-pci,host=00:16.0,bus=pcie.0,addr=0x03
  
  # network
  -netdev user,id=net0
  -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:AB:DC:A8,addr=0x04
  
  # rx570
  -device pcie-root-port,id=pcie.1,bus=pcie.0,addr=1c.0,slot=1,chassis=0,multifunction=on,x-speed=8,x-width=4 # or ioh3420
  -device vfio-pci,id=gfx0,host=0a:00.0,multifunction=on,bus=pcie.1,addr=00.0,x-no-kvm-intx=on
  -device vfio-pci,host=0a:00.1,bus=pcie.1,addr=00.1
  
  # usb controllers (from egpu case)
  -device vfio-pci,host=0d:00.0,bus=pcie.0,addr=0x08
  -device vfio-pci,host=0e:00.0,bus=pcie.0,addr=0x09
  
  # others
  -global ICH9-LPC.disable_s3=1
  -global ICH9-LPC.disable_s4=1
  -global ICH9-LPC.acpi-pci-hotplug-with-bridge-support=off
)

/home/myozov/Desktop/qemu-7.1.0/build/qemu-system-x86_64 "${args[@]}" > debug

