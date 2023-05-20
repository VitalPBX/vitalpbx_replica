#!/bin/bash
# This code is the property of VitalPBX LLC Company
# License: Proprietary
# Date: 20-May-2023
# VitalPBX Recording Replica with Lsync
#
set -e
function jumpto
{
    label=$start
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

echo -e "\n"
echo -e "************************************************************"
echo -e "*  Welcome to the VitalPBX Recording Replica installation  *"
echo -e "*                All options are mandatory                 *"
echo -e "************************************************************"

filename="config.txt"
if [ -f $filename ]; then
	echo -e "config file"
	n=1
	while read line; do
		case $n in
			1)
				ip_master=$line
  			;;
		esac
		n=$((n+1))
	done < $filename
	echo -e "IP New Server............ > $ip_master"	
fi

while [[ $ip_master == '' ]]
do
    read -p "IP Server 1............. > " ip_master 
done 

echo -e "************************************************************"
echo -e "*                   Check Information                      *"
echo -e "*           Make sure both servers see each other          *"
echo -e "************************************************************"
while [[ $veryfy_info != yes && $veryfy_info != no ]]
do
    read -p "Are you sure to continue with this settings? (yes,no) > " veryfy_info 
done

if [ "$veryfy_info" = yes ] ;then
	echo -e "************************************************************"
	echo -e "*                Starting to run the scripts               *"
	echo -e "************************************************************"
else
    	exit;
fi

cat > config.txt << EOF
$ip_master
$ip_standby
EOF

create_lsyncd_config_file:
echo -e "************************************************************"
echo -e "*             Configure Sync in Old Server                 *"
echo -e "************************************************************"

cat > /etc/lsyncd.conf << EOF
----
-- User configuration file for lsyncd.
--
-- Simple example for default rsync.
--
settings {
		logfile    = "/var/log/lsyncd/lsyncd.log",
		statusFile = "/var/log/lsyncd/lsyncd-status.log",
		statusInterval = 20,
		nodaemon   = true,
		insist = true,
}
sync {
		default.rsync,
		source="/var/spool/asterisk/monitor",
		target="$ip_standby:/var/spool/asterisk/monitor",
		delete = 'running',
                --delay = 5,
		rsync={
                		-- timeout = 3000,
                		update = true,
                		_extra={"--temp-dir=/home/sync/var/spool/asterisk/monitor_temp/"},
                		times = true,
                		archive = true,
                		compress = true,
                		perms = true,
                		acls = true,
                		owner = true,
				group = true
		}
}
EOF

systemctl enable lsyncd.service
systemctl start lsyncd.service

vitalpbx_cluster_ok:
echo -e "************************************************************"
echo -e "* Record Replication has started, this process can take a  *"
echo -e "* long time depending on the number of recordings, you can *"
echo -e "* monitor the process by running the following command:    *"
echo -e "************************************************************"
