# OSX-KVM


# Modules (/etc/modules-load.d)
kvm.conf:\
kvmgt\
vfio\
vfio_iommu_type1\
vfio_pci\
vfio_virqfd\


# Options (/etc/modprobe.d)
iommu_unsafe_interrupts.conf:\
options vfio_iommu_type1 allow_unsafe_interrupts=1

kvm.conf:\
options kvm ignore_msrs=Y report_ignored_msrs=0

kvm-intel.conf:\
options kvm-intel nested=Y

vfio-pci.conf:\
options vfio-pci ids=1002:67df,1002:aaf0 disable_vga=1 disable_idle_d3=1\
softdep i915 pre: vfio-pci\
softdep mei_me pre: vfio-pci\
softdep radeon pre: vfio-pci\
softdep amdgpu pre: vfio-pci\
softdep drm pre: vfio-pci\
softdep snd_hda_intel pre: vfio-pci
