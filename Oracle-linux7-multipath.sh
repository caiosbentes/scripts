#!/bin/bash
#
# glpi.sh
#
# Autor     : Caio Bentes <caio.bentes@solustecnologia.com.br>
#
#  -------------------------------------------------------------
#   This script onfigure device-mapper-multipath in OS Oracle Linux 7.6
#

# Install the iscsi-initiator-utils package:
yum install iscsi-initiator-utils -y


# Initialize the /etc/multipath.conf file:
mpathconf --enable

# Make backup of /etc/multipath.conf
cp -pRf /etc/multipath.conf /root/multipath.conf.bkp 

# Obtain the WWID of a SCSI device
/usr/lib/udev/scsi_id -g -u -d /dev/sdb

# Obtain the WWID of a SCSI device
/usr/lib/udev/scsi_id -g -u -d /dev/sdc


# Modify the sections in /etc/multipath.conf
cat <<EOF >> /etc/multipath.conf 
defaults {
        udev_dir /dev
        polling_interval 10
        selector "round-robin 0"
        path_grouping_policy multibus
        getuid_callout "/sbin/scsi_id -g -u -s /block/%n"
        prio_callout /bin/true
        path_checker readsector0
        rr_min_io 100
        max_fds 8192
        rr_weight priorities
        failback immediate
        no_path_retry fail
        user_friendly_names yes
}

blacklist { 
wwid 36d09466085adfd0023cf99ce908ea353 
devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*" 
devnode "^hd[a-z]" 
}

multipaths {
multipath {
wwid 36000d3100473bc000000000000000015
alias blue
}
multipath {
wwid 36000d3100473bc000000000000000015
alias green
}
}
EOF

# Restart your multipath daemon service using the following command:
service multipathd restart

# Configure the service to start after system reboots
systemctl enable multipathd

# Verify that your multipath volumes alias are displayed properly by running the following command: multipath –ll
multipath -ll
