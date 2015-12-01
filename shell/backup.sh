#!/bin/bash

# author: Mikael Flood <thernx@gmail.com>

Days="31"
Path="/storage/backup"
Archive="$Path/$HOSTNAME-$(date +%F).tgz"
Cleaup=($(find "$Path" -mtime +"$Days"))

# list files to backup and create archive
touch "$Archive"
chmod 600 "$Archive"
tar -z -c -f "$Archive" \
    /etc/passwd \
    /etc/fstab \
	/etc/salt \
    /etc/sysctl.conf \
    /etc/network/interfaces \
    /etc/ssh/sshd_config \
    /var/log/messages \
    /var/log/syslog \
    /var/log/auth.log \
    /usr/local \
    /storage/htdocs \
    /storage/salt \
    /etc/libvirt/qemu/ \
    /storage/srv/ \

if [ $? != 0 -o ! -e $Archive ] ; then
    echo "$Archive: not created"
    echo "cleanup: aborted"
    exit 1
fi

echo "$Archive: created"

if [ ! -z "$Cleaup" ] ; then
    for file in ${Cleaup[*]}; do
        /bin/rm "$file" && echo "$file: removed"
    done
fi
