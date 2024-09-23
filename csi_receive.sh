#!/usr/bin/sudo /bin/bash
cd lorcon-old
./configure
make
sudo make install
cd ~
cd linux-80211n-csitool-supplementary/netlink/
make
sudo bash ./monitor.sh wlp4s0 64 HT20
sudo ./log_to_file 0406.dat

