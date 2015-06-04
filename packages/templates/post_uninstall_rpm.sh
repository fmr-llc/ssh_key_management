#!/usr/bin/env bash
SSH_VERSION=`rpm -q openssh | cut -d'-' -f1-2`
RUNAS_VERSION="openssh-5.3p1"

if [[ "$SSH_VERSION" < "$RUNAS_VERSION" ]]; then
    (crontab -l 2>/dev/null |grep -v authorized_keys_cron.sh) | crontab -
else
    mv /etc/ssh/sshd_config.previous /etc/ssh/sshd_config
    rm -rf /etc/ssh/cache
    service sshd restart
    userdel -r _sshkeys
fi

rm /etc/rc.d/rc3.d/S99RegisterHostWithSSHKM
