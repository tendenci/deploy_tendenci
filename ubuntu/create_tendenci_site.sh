#!/bin/sh -e

# must run as root
u=`whoami`
if [ $u != "root" ]; then
echo
echo "Error: Must run as root! Type 'sudo su' then try again.";
exit;
fi

# prompt for site name
echo "This script will create a tendenci site for you."
echo
read -p "Site name (leave blank to use 'tendenci'): " SITE_NAME

# trim white spaces and convert to lowercase
SITE_NAME=`echo "$SITE_NAME" | sed -e 's/ //g' | tr [:upper:] [:lower:]`

[ "$SITE_NAME" != "" ] || SITE_NAME=tendenci

# check if site name already exists
SITE_DIR=/var/www/$SITE_NAME
if [ -d "$SITE_DIR" ]; then
	echo "Site name '$SITE_NAME' already exists."
	exit
fi

PORT=8000
# prompt for port
echo
read -p "Port - 4-digits and starting with 8 (leave blank to use '8000'): " MY_PORT
re="^8[0-9]{3}$"
#[[ "$PORT" =~ $re ]] || PORT=8000
if echo "$MY_PORT" | egrep -q '^8[0-9]{3}$'; then
    PORT=$MY_PORT
fi
echo $PORT

# prompt for nginx server_name
echo
read -p "Server name (leave blank to use 'localhost'): " SERVER_NAME
SERVER_NAME=`echo "$SERVER_NAME" | sed -e 's/ //g'`
[ "$SERVER_NAME" != '' ] || SERVER_NAME='localhost'

DB_NAME=$SITE_NAME
DB_USER=$SITE_NAME
DB_PASS=$(mcookie)

TENDENCI_USERNAME=admin
TENDENCI_PASSWD=admin
USER_EMAIL=admin@example.com

# create the tendenci site folder
mkdir -p $SITE_DIR
cd $SITE_DIR

virtualenv venv --distribute
. venv/bin/activate

pip install tendenci

create-tendenci-project

pip install -r requirements/dev.txt
pip install gevent==0.13.8

# start postgresql
service postgresql restart

# create tendenci database
psql -U postgres -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
psql -U postgres -c "CREATE DATABASE $DB_NAME WITH OWNER $DB_USER;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# update DATABASE_URL in .env
sed -i "s|DATABASE_URL\s*=\(.*\)|DATABASE_URL='postgres://$DB_USER:$DB_PASS@localhost/$DB_NAME'|" .env

# add some variables in .env
echo "LOCAL_MEMCACHED_URL='127.0.0.1:11211'" >> .env
echo "EMAIL_HOST='localhost'" >> .env
echo "EMAIL_PORT='25'" >> .env
echo "HAYSTACK_SEARCH_ENGINE='whoosh'" >> .env
echo "SECRET_KEY='$(mcookie)$(mcookie)'" >> .env

# run deploy.py
python deploy.py

# create tendenci superuser
cat>>$SITE_DIR/create_superuser.py<<EOF
import os
os.environ['DJANGO_SETTINGS_MODULE'] = 'conf.settings'
import conf.settings
from django.contrib.auth.models import User
u = User.objects.create_superuser('$TENDENCI_USERNAME', '$USER_EMAIL', '$TENDENCI_PASSWD')
EOF
python $SITE_DIR/create_superuser.py
rm $SITE_DIR/create_superuser.py

# install default data
python manage.py load_npo_defaults

# update index
python manage.py update_index

# create tendenci user and group
#u_tendenci=`grep tendenci /etc/passwd`
#if [ -z "$u_tendenci" -o "$u_tendenci"=="" ]; then
#	useradd tendenci -d /nonexistent
#	groupadd -f tendenci
#	usermod -a -G tendenci tendenci
#fi

# set up gunicorn
wget -O /etc/init/$SITE_NAME.conf https://gist.github.com/jennyq/246c76316536e283f008/raw/f9f3d9055343795ddae3e4fd813cf5d3bc7b32c9/tendenci.conf
sed -i "s|/var/www/tendenci|/var/www/$SITE_NAME|" /etc/init/$SITE_NAME.conf
sed -i "s|8000|$PORT|" /etc/init/$SITE_NAME.conf

service $SITE_NAME restart

# set up nginx conf for site
wget -O /etc/nginx/sites-available/$SITE_NAME https://gist.github.com/jennyq/7742140/raw/b9320f9d13d5da3765812456f3f81aa83e48336c/nginx_tendenci
sed -i "s|tendenci|$SITE_NAME|" /etc/nginx/sites-available/$SITE_NAME

[ $PORT = 8000 ] || sed -i "s|8000|$PORT|" /etc/nginx/sites-available/$SITE_NAME
[ $SERVER_NAME = "localhost" ] || sed -i "s|server_name localhost|server_name $SERVER_NAME|" /etc/nginx/sites-available/$SITE_NAME

# create a symlink
if [ ! -d /etc/nginx/sites-enabled ]; then
mkdir /etc/nginx/sites-enabled
fi
ln -s /etc/nginx/sites-available/$SITE_NAME /etc/nginx/sites-enabled/$SITE_NAME

# remove nginx default
if [ -f /etc/nginx/sites-enabled/default ]; then
rm /etc/nginx/sites-enabled/default
fi

service nginx restart

echo
echo "Successfully created the site $SITE_NAME"
echo
echo "Site directory: /var/www/$SITE_NAME"
echo "Site Nginx conf: /etc/nginx/sites-available/$SITE_NAME"
echo "Site upstart conf: /etc/init/$SITE_NAME.conf"
echo "Site login username: admin, password: admin"


