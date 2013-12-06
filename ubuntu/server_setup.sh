#!/bin/sh -ex

echo "This script will set up the server - install dependencies for tendenci site."

# check python version
python_version=`python --version 2>&1 | awk '{print $2}' | cut -c1-3`
if [ $python_version != "2.7" ]; then
    echo "The python version $python_version is not supported. Please install Python 2.7!"
    exit
fi

# must be root
u=`whoami`
if [ $u != "root" ]; then
echo "Error: Must run as root! Type 'sudo su' then try again.";
exit;
fi

apt-get update
apt-get install -y build-essential
apt-get install -y python-dev

apt-get install -y libevent-dev
apt-get install -y libpq-dev
apt-get install -y memcached
apt-get install -y libmemcached-dev
apt-get install -y libjpeg8
apt-get install -y libjpeg-dev
apt-get install -y libfreetype6
apt-get install -y libfreetype6-dev
apt-get install -y postgresql
apt-get install -y nginx

[ -f /usr/lib/libz.so ] || ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/
[ -f /usr/lib/libjpeg.so ] || ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/
[ -f /usr/lib/libfreetype.so ] || ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib/

PGSQL_VER=$(ls /etc/postgresql/)
CONF_DIR=/etc/postgresql/${PGSQL_VER}/main
sed -i "/^local.*postgres/ s/peer/trust/" $CONF_DIR/pg_hba.conf 

# install pip
#wget http://python-distribute.org/distribute_setup.py | python
#rm distribute_setup.py

apt-get install python-setuptools
easy_install pip
pip install virtualenv

