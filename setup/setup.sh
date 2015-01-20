#!/usr/bin/env bash

# majordomus root location
MAJORDOMUS_BASE=/opt/majordomus
MAJORDOMUS_ROOT=/opt/majordomus/majord
MAJORDOMUS_DATA=/opt/majordomus/majord-data
MAJORDOMUS_USER=majord

# functions used in the scripts
source setup/functions.sh

# update system packages to make sure we have the latest upstream versions of things from Ubuntu.
echo "***"
echo "*** majordomus: updating ubuntu first"
echo "***"

hide_output apt-get update
hide_output apt-get -y upgrade

# install some basic
apt_install unzip curl sysstat build-essential git

# make sure we are on a defined local
if [ -z `locale -a | grep en_US.utf8` ]; then
    # generate locale if not exists
    hide_output locale-gen en_US.UTF-8
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# load global vars
if [ ! -f "/etc/majord.conf" ]; then
	sudo cp conf/majord.conf /etc/majord.conf	
fi
source /etc/majord.conf # load global vars

# create a majordomus user next
sudo su -c "useradd $MAJORDOMUS_USER -s /bin/bash -m -g sudo"
sudo chpasswd << 'END'
majord:majord
END

echo "***"
echo "*** majordomus: installing services"
echo "***"

source setup/system.sh
source setup/ssl.sh
source setup/web.sh
source setup/docker.sh
source setup/consul.sh
source setup/buildenv.sh

echo "***"
echo "*** majordomus: cleanup"
echo "***"

sudo apt-get clean
