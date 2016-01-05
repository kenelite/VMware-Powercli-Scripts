#!/bin/bash
#===============================================================================
# SCRIPT			example-tmp.sh
# All Rights Reserved 
#===============================================================================

HOSTNAME=$1
IP=$2
GATEWAY1=$3
GATEWAY2=$4
FILENAME="/tmp/$HOSTNAME.log"

#删除eth0 eth1 网关信息
function delgateway()
{

	echo "delete the eth0 dns information"
		
	sed -i '/DNS/d'   /etc/sysconfig/network-scripts/ifcfg-eth0
	sed -i '/DOMAIN/d'   /etc/sysconfig/network-scripts/ifcfg-eth0
	
	echo "delete the eth1 gateway"
	
	sed -i '/GATEWAY/d'   /etc/sysconfig/network-scripts/ifcfg-eth1
	sed -i '/DNS/d'   /etc/sysconfig/network-scripts/ifcfg-eth1
	sed -i '/DOMAIN/d'   /etc/sysconfig/network-scripts/ifcfg-eth1
	

}


#更改hosts 错误的主机名
function changehosts()
{
	echo "change the hosts and network information"
	
	sed -i '/^'$IP'/d'   /etc/hosts
	echo -e  "$IP \t $HOSTNAME"  >> /etc/hosts
	
	sed -i '/HOSTNAME=/d' /etc/sysconfig/network
	echo "HOSTNAME=$HOSTNAME"  >> /etc/sysconfig/network

}


#重新扫描sdb
function rescandisk()
{
	
	echo "resize sdb and pv VolGroup01-LogVol01_data"
	
	echo 1 > /sys/block/sdb/device/rescan
	pvresize /dev/sdb
	lvextend -l 100%VG  -r /dev/mapper/VolGroup01-LogVol01_data 

}



#读取CPU,MEM
function getcpumem()
{
	
	echo "===== cpuinfo =====" >> $FILENAME
	cat /proc/cpuinfo >> $FILENAME
	
	echo "===== free =====" >> $FILENAME
	free -m >> $FILENAME

	echo "===== meminfo =====" >> $FILENAME
	cat /proc/meminfo  >> $FILENAME
}

#读取存储配置
function  getalldiskinfo()
{
	
	echo >> $FILENAME
	echo "===== pvs =====" >> $FILENAME
	pvs >> $FILENAME
	echo >> $FILENAME

	echo "===== vgs =====" >> $FILENAME
	vgs >> $FILENAME
	echo >> $FILENAME

	echo "===== lvs =====" >> $FILENAME
	lvs >> $FILENAME
	echo >> $FILENAME

	echo "===== df -h =====" >> $FILENAME
	df -h >> $FILENAME

}

#读取网络配置
function getallnetworkinfo()
{

	echo >> $FILENAME
	echo "===== /etc/hosts =====" >> $FILENAME
	cat /etc/hosts >> $FILENAME

	echo >> $FILENAME
	echo "===== /etc/sysconfig/network =====" >> $FILENAME
	cat /etc/sysconfig/network >> $FILENAME

	echo >> $FILENAME
	echo "===== /etc/resolv.conf =====" >> $FILENAME
	cat /etc/resolv.conf  >> $FILENAME

	echo >> $FILENAME
	echo "=====  eth0  =====" >> $FILENAME
	cat /etc/sysconfig/network-scripts/ifcfg-eth0  >> $FILENAME


	echo >> $FILENAME
	echo "===== ping $GATEWAY1 =====" >> $FILENAME
	ping -c 5 $GATEWAY1  >> $FILENAME

	echo >> $FILENAME
	echo "===== eth1 =====" >> $FILENAME
	cat /etc/sysconfig/network-scripts/ifcfg-eth1  >> $FILENAME


	echo >> $FILENAME
	echo "===== ping $GATEWAY2 ======" >> $FILENAME
	ping -c 5 $GATEWAY2  >> $FILENAME
	echo >> $FILENAME

}


function main()
{

	echo "===== Configuration information  of $HOSTNAME ===">> $FILENAME
	
	delgateway

	changehosts
	
	rescandisk

	getcpumem
	
	getalldiskinfo

	getallnetworkinfo
	
	echo "===== END ===">> $FILENAME

}


main 


#end
