# NVIDIA Related Things

## Install NVIDIA Drivers

Reference: [virtualcuriosities](https://www.virtualcuriosities.com/articles/1788/how-to-install-nvidia-drivers-in-linux-mint), [stackoverflow](https://stackoverflow.com/questions/42984743/nvidia-smi-has-failed-because-it-couldnt-communicate-with-the-nvidia-driver)

1. Install driver
2. Enroll key (add MOK)

```sh
# Check if secure boot is enabled and driver is registered
mokutil --sb-state
inxi -Gxxz
# If the above works, then the below might
nvidia-smi
# Else, some re-install will be needed and the above reference needs to be followed
sudo dkms status nvidia
sudo dkms remove nvidia/580.82.07 --all
sudo dkms install --force nvidia/580.82.07 -k $(uname -r)
sudo update-initramfs -u
sync
reboot
```
