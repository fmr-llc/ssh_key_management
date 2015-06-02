#!/usr/bin/env bash
SSH_VERSION=`rpm -q openssh | cut -d'-' -f1-2`
RUNAS_VERSION="openssh-5.3p1"

setup_authorized_keys_cron_job () {
    chmod 500 /etc/ssh/authorized_keys_cron.sh
    (crontab -l 2>/dev/null; echo "*/15 * * * * /etc/ssh/authorized_keys_cron.sh >/dev/null 2>&1") | crontab -
}

setup_authorized_keys_script () {
    getent passwd _sshkeys > /dev/null 2>&1 || useradd -s /sbin/nologin -r -M _sshkeys
    getent passwd _sshkeys > /dev/null 2>&1 || exit $?

    mkdir /etc/ssh/cache/ 2>/dev/null
    mkdir /etc/ssh/cache/authorized_keys 2>/dev/null
    mkdir /etc/ssh/cache/tmp 2>/dev/null
    chmod 770 -R /etc/ssh/cache/

    chown root:_sshkeys /etc/ssh/authorized_keys.sh
    chown root:root /etc/ssh/sshd_config
    chown root:_sshkeys -R /etc/ssh/cache/
    chmod 750 /etc/ssh/authorized_keys.sh
    chmod 600 /etc/ssh/sshd_config

    service sshd restart
}

if [[ "$SSH_VERSION" < "$RUNAS_VERSION" ]]; then
    echo "Must use cron method (~/.ssh/authorized_keys2)"
    rm /etc/sshd_config.unix rm /etc/sshd_config.rhel6 /etc/authorized_keys.sh
    setup_authorized_keys_cron_job
elif [[ "$SSH_VERSION" == "$RUNAS_VERSION" ]]; then
    echo "Must use authorized_keys script with AuthorizedKeysCommandRunAs"
    rm /etc/ssh/sshd_config.unix /etc/ssh/authorized_keys_cron.sh
    mv --suffix=.previous /etc/ssh/sshd_config.rhel6 /etc/ssh/sshd_config
    setup_authorized_keys_script
else
    echo "Must use authorized_keys script with AuthorizedKeysCommandUser"
    rm /etc/ssh/sshd_config.rhel6 /etc/ssh/authorized_keys_cron.sh
    mv --suffix=.previous /etc/ssh/sshd_config.unix /etc/ssh/sshd_config
    setup_authorized_keys_script
fi
