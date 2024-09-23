#!/usr/bin/sudo /bin/bash
cd lorcon-old
./configure
make
sudo make install
cd ~
cd linux-80211n-csitool-supplementary/injection/
make
sudo bash ./inject.sh wlp4s0 64 HT20
echo 0x1c113 | sudo tee `sudo find /sys -name monitor_tx_rate`
sudo ./random_packets 1000000000 100 1 100000

