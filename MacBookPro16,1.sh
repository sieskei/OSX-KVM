#!/usr/bin/env bash

ALLOCATED_RAM="24576" # MiB

args=(
  -enable-kvm
  -machine q35,vmport=off,sata=off,usb=off
  -m "$ALLOCATED_RAM"
  -cpu host,kvm=off,vendor=GenuineIntel,+kvm_pv_unhalt,+kvm_pv_eoi,+hypervisor,+invtsc
  -smp 12,cores=1,sockets=6,threads=2,maxcpus=12
  -no-hpet
  -rtc base=localtime,clock=host

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
  -drive id=OpenCore,if=none,snapshot=on,format=qcow2,file="./images/OpenCore/build/igpu.qcow2"
  -drive id=MacOS,if=none,format=qcow2,file="./images/monterey_hdd_ng.img"

  # igpu
  -device vfio-pci,host=00:02.0,bus=pcie.0,addr=0x02,romfile="./i915ovmf/i915ovmf_dvmt_64mb_edid.rom",x-igd-opregion=on,x-igd-gms=58

  # heci
  -device vfio-pci,host=00:16.0,bus=pcie.0,addr=0x03

  # usb controllers
  -device vfio-pci,host=00:14.0,bus=pcie.0,addr=0x04 # main
  -device vfio-pci,host=3d:00.0,bus=pcie.0,addr=0x05 # c

  # wifi
  -device vfio-pci,host=03:00.0,bus=pcie.0,addr=0x07

  # network
  -netdev user,id=net0
  -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:AB:DC:A8,addr=0x08

  # others
  -global ICH9-LPC.disable_s3=1
  -global ICH9-LPC.disable_s4=1
  -global ICH9-LPC.acpi-pci-hotplug-with-bridge-support=off
)

/home/myozov/Desktop/qemu-7.1.0/build/qemu-system-x86_64 "${args[@]}" > debug
