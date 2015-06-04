#!/usr/bin/env bash

mv /etc/ssh/sshd_config.previous /etc/ssh/sshd_config
rm -rf /etc/ssh/cache
service ssh restart
userdel -r _sshkeys

rm /etc/rc.d/rc3.d/S99RegisterHostWithSSHKM
