#!/usr/bin/env bash

setup_authorized_keys_script () {
    getent passwd _sshkeys > /dev/null 2>&1 || useradd -s /sbin/nologin -r -M _sshkeys
    getent passwd _sshkeys > /dev/null 2>&1 || exit $?

    mkdir /etc/ssh/cache/
    mkdir /etc/ssh/cache/authorized_keys
    mkdir /etc/ssh/cache/tmp
    chmod 770 -R /etc/ssh/cache/

    chown root:_sshkeys /etc/ssh/authorized_keys.sh
    chown root:root /etc/ssh/sshd_config
    chown root:_sshkeys -R /etc/ssh/cache/
    chmod 750 /etc/ssh/authorized_keys.sh
    chmod 600 /etc/ssh/sshd_config

    service ssh restart
}

echo "Must use authorized_keys script with AuthorizedKeysCommandUser"
mv --suffix=.previous /etc/ssh/sshd_config.unix /etc/ssh/sshd_config
setup_authorized_keys_script
