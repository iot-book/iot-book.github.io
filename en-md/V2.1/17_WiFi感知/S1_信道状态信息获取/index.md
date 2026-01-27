# WiFi Sensing

Using WiFi signals for human and environmental detection and sensing is a widely researched technology in the field of wireless sensing. In this research domain, analyzing Channel State Information (CSI) from WiFi signals enables significantly higher sensing accuracy compared to using signal strength or similar metrics.

## Obtaining CSI Information

Currently, the mainstream tools for acquiring WiFi CSI information include:

- [Linux 802.11n CSI Tool](https://dhalperi.github.io/linux-80211n-csitool/)
- [ESP32 CSI Toolkit](https://stevenmhernandez.github.io/ESP32-CSI-Tool/)
- [Atheros CSI Tool](https://wands.sg/research/wifi/AtherosCSI/)
- [PicoScenes-WiFi](https://ps.zpj.io)

The corresponding hardware for these tools includes Intel 5300 wireless network cards, ESP32 Node MCUs, and certain Qualcomm-chip-based wireless network cards. We use the Linux 802.11n CSI Tool as an example to illustrate how to obtain WiFi CSI information:

### Hardware and Software Requirements

An Intel 5300 wireless network card and a Linux operating system with kernel version 4.15 (such as Ubuntu 16.04.4) are required. Follow the installation guide at https://github.com/spanev/linux-80211n-csitool to install the CSI tool on newer kernels (4.15).

### Installation Procedure

1. Install dependencies

~~~bash
sudo apt install build-essential linux-headers-$(uname -r) git-core
~~~

2. Install a newer version of the compiler toolchain

~~~bash
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install gcc-8 g++-8
# Replace with the newer compiler toolchain
sudo rm /usr/bin/gcc
sudo rm /usr/bin/g++
sudo ln -s /usr/bin/gcc-8 /usr/bin/gcc
sudo ln -s /usr/bin/g++-8 /usr/bin/g++
~~~

3. Compile and install the modified wireless driver

~~~bash
git clone https://github.com/spanev/linux-80211n-csitool.git
cd linux-80211n-csitool
CSITOOL_KERNEL_TAG=csitool-$(uname -r | cut -d . -f 1-2)
git checkout ${CSITOOL_KERNEL_TAG}
make -j `nproc` -C /lib/modules/$(uname -r)/build M=$(pwd)/drivers/net/wireless/intel/iwlwifi modules
sudo make -C /lib/modules/$(uname -r)/build M=$(pwd)/drivers/net/wireless/intel/iwlwifi \
INSTALL_MOD_DIR=updates modules_install
sudo depmod
cd ..
~~~

4. Replace the modified firmware

~~~bash
git clone https://github.com/dhalperi/linux-80211n-csitool-supplementary.git
for file in /lib/firmware/iwlwifi-5000-*.ucode; do sudo mv $file $file.orig; done
sudo cp linux-80211n-csitool-supplementary/firmware/iwlwifi-5000-2.ucode.sigcomm2010 /lib/firmware/
sudo ln -s iwlwifi-5000-2.ucode.sigcomm2010 /lib/firmware/iwlwifi-5000-2.ucode
~~~

## Related Papers

1. Smokey: Ubiquitous smoking detection with commercial WiFi infrastructures, X Zheng, J Wang, L Shangguan, Z Zhou, Y Liu, IEEE INFOCOM 2016