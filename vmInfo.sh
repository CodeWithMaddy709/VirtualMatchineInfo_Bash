#!/bin/bash


# install required pacaged 
sudo apt install net-tools -y  || yum install net-tools
sudo apt install hwinfo -y
wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
chmod +x speedtest-cli

clear
echo "========================================= Basic Information ========================================="
echo -e "HostName: "  `hostname -s `
echo -e "SMBiosId: " `sudo dmidecode -t system | grep -i UUID: | awk '{print $2}'`
echo -e "IPAddress: " `hostname -I | awk '{print $1}'`
echo -e "MACAddress: " `sudo cat /sys/class/net/*/address | head -n 1`
echo -e "HostName: " `cat /etc/hosts | head -n 2 | tail -n 1 | awk '{print $2}'`
echo -e "OS architecture: " `sudo getconf LONG_BIT` "bit"
echo -e "Firmware Boot Type: " `[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS`
echo "========================================= VM Information ============================================"
echo -e "VMware.MoRefId: " `sudo dmidecode -t system | grep -i UUID: | awk '{print $2}'| sed s/-//g`
echo -e "VMware.VCenterId: " `sudo dmidecode -t chassis | grep Manufacturer: | awk '{print $2,$3}'`
echo -e "VMware.VMName: " `sudo dmidecode -t system | grep "Product Name:" | awk '{print $3}'`
echo -e "VMware.vmFolderPath: VMware/"`sudo dmidecode -t system | grep "Product Name:" | awk '{print $3}'`
echo "========================================= CPU Information ============================================"
echo -e "CPU.NumberOfProcessors: " `lscpu  | grep -w "CPU(s):" | head -n 1 | awk '{print $2}'`
echo -e "CPU.NumberOfCores: " `lscpu -b -p=Core,Socket | grep -v '^#' | sort -u | wc -l`
echo -e "CPU.NumberOfLogicalCores: " `grep --count ^processor /proc/cpuinfo`
echo "========================================= OS Information ============================================"
echo -e "OS.Name: " `egrep '^(NAME)=' /etc/os-release`
echo -e "OS.Version: " `egrep '^(VERSION)=' /etc/os-release`
echo "========================================= RAM Information ============================================"
echo -e "RAM.TotalSizeInMB: " `free -m | head -n 2 | tail -n 1 | awk '{print $2 }'`
echo -e "RAM.UsedSizeInMB.Avg: " `free -m | head -n 2 | tail -n 1 | awk '{print $3}'`
echo -e "RAM.UsedSizeInMB.Max: " `free -m | head -n 2 | tail -n 1 | awk '{print $3+$4+$6}'`
echo "========================================= CPU USAGE  Information ====================================="
UsagePct=`echo " "$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]""`
echo -e "CPU.UsagePct.Avg: $UsagePct%"
total=$(getconf CLK_TCK)
total=$((total - UsagePct))
echo -e "CPU.UsagePct.Max: $total%"
echo "========================================= Disk Information ============================================"
NoDisk=`lsblk -S | grep  "^sd" | wc -l`
echo -e "Number of disks: " $NoDisk
echo -e "Disk 1 size (In GB): " `lsblk  | grep "^s" | head -n 1 |  awk '{print $4}'`"B"
echo -e "Disk1ReadsPerSecondInKB.Avg: " `sudo hdparm -t /dev/sda | tail -n 1 | awk '{print $11*1000 ,"kb"}'`
echo -e "Disk1WritesPerSecondInKB.Avg: " `sudo hdparm -t /dev/sda | tail -n 1 | awk '{print $11*1000 ,"kb"}'`
echo -e "Disk1ReadsPerSecondInKB.Max: " `sudo hdparm -t /dev/sda | tail -n 1 | awk '{print $11*1024 ,"kb"}'`
echo -e "Disk1WritesPerSecondInKB.Max: " `sudo hdparm -t /dev/sda | tail -n 1 | awk '{print $11*1024 ,"kb"}'`
echo -e "Disk1ReadOpsPerSecond.Avg: " `sudo hdparm -T /dev/sda  | tail -n 1 | awk '{print $10*1000 }'`
echo -e "Disk1WriteOpsPerSecond.Avg: " `sudo hdparm -T /dev/sda  | tail -n 1 | awk '{print $10*1000 }'`
echo -e "Disk1ReadOpsPerSecond.Max " `sudo hdparm -T /dev/sda  | tail -n 1 | awk '{print $10*1024 }'`
echo -e "Disk1WriteOpsPerSecond.Max " `sudo hdparm -T /dev/sda  | tail -n 1 | awk '{print $10*1024 }'`
echo "========================================= Network Information ============================================"
echo -e "NetworkReadsPerSecondInKB.Avg: " `ifconfig | grep "RX packets" | head -n 1 | awk '{print $6,$7}' | tr -d '(MB)'  | awk '{print $1*1000,"Kb"}'`
echo -e "NetworkWritesPerSecondInKB.Avg: " `ifconfig | grep "TX packets" | head -n 1 | awk '{print $6,$7}' | tr -d '(MB)'| awk '{print $1*1000,"Kb"}'`
echo -e "NetworkReadsPerSecondInKB.Max: " `ifconfig | grep "RX packets" | head -n 1 | awk '{print $6,$7}' | tr -d '(MB)'  | awk '{print $1*1024,"Kb"}'`
echo -e "NetworkWritesPerSecondInKB.Max: " `ifconfig | grep "TX packets" | head -n 1 | awk '{print $6,$7}' | tr -d '(MB)'| awk '{print $1*1024,"Kb"}'`
echo -e "Network adapters: " `ip route show | head -n 1 | awk '{print $5}'`
echo -e "Network In throughput: " `ifconfig | grep "RX packets" | head -n 1 | awk '{print $6,$7}'`
echo -e "Network Out throughput: " `ifconfig | grep "TX packets" | head -n 1 | awk '{print $6,$7}'`
echo "========================================= Applications Information ========================================"
ps aux | sed '1d' | awk 'BEGIN{print "Owner        Application "}{print "Application"NR,$1,$11}'
