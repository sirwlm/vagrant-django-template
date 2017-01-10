#!/bin/bash

# Script to set up a Django project on Vagrant.

# Installation settings

PROJECT_NAME=$1

DB_NAME=$PROJECT_NAME
VIRTUALENV_NAME=$PROJECT_NAME

PROJECT_DIR=/home/vagrant/$PROJECT_NAME
VIRTUALENV_DIR=/home/vagrant/.virtualenvs/$PROJECT_NAME
LOCAL_SETTINGS_PATH="/$PROJECT_NAME/settings/local.py"
DJANGO_DIR=$PROJECT_DIR

# Install essential packages from Apt
apt-get update -y
apt-get upgrade -y

# Update bash_aliases with correct projcet_dir
mv $PROJECT_DIR/etc/install/bashrc $PROJECT_DIR/etc/install/bashrc.sed
mv $PROJECT_DIR/etc/install/bashalias $PROJECT_DIR/etc/install/bashalias.sed

sed -e 's/DJANGO_DIR/$PROJECT_DIR/g' $PROJECT_DIR/etc/install/bashrc.sed > $PROJECT_DIR/etc/install/bashrc
sed -e 's/DJANGO_DIR/$PROJECT_DIR/g' $PROJECT_DIR/etc/install/bashalias.sed > $PROJECT_DIR/etc/install/bashalias


echo 'Updated bashrc and bash_alias (run whichalias to see available commands)'

# Python dev packages
apt-get install -y build-essential python python3-dev
wget https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tgz
tar -xzf Python-3.6.0.tgz
cd Python-3.6.0 && ./configure && make install && cd ..

# python-setuptools being installed manually
wget https://bootstrap.pypa.io/ez_setup.py -O - | python3.6
# Dependencies for image processing with Pillow (drop-in replacement for PIL)
# supporting: jpeg, tiff, png, freetype, littlecms
# (pip install pillow to get pillow itself, it is not in requirements.txt)
apt-get install -y libjpeg-dev libtiff-dev zlib1g-dev libfreetype6-dev liblcms2-dev
# Git (we'd rather avoid people keeping credentials for git commits in the repo, but sometimes we need it for pip requirements that aren't in PyPI)
apt-get install -y git
apt-get install -y nodejs npm babel

# Postgresql
if ! command -v psql; then
    apt-get install -y postgresql libpq-dev
    # Create vagrant pgsql superuser
    su - postgres -c "createuser -s vagrant"
fi

# virtualenv global setup
if ! command -v pip; then
    easy_install -U pip
fi
if [[ ! -f /usr/local/bin/virtualenv ]]; then
    pip3.6 install virtualenv virtualenvwrapper stevedore virtualenv-clone
fi

# bash environment global setup
cp -p $PROJECT_DIR/etc/install/bashrc /home/vagrant/.bashrc
cp -p $PROJECT_DIR/etc/install/bashalias /home/vagrant/.bash_alias

# ---

# postgresql setup for project
su - vagrant -c "createdb $DB_NAME"

# virtualenv setup for project
su - vagrant -c "/usr/local/bin/virtualenv $VIRTUALENV_DIR --python=/usr/bin/python3 && \
    echo $PROJECT_DIR > $VIRTUALENV_DIR/.project && \
    $VIRTUALENV_DIR/bin/pip install -r $PROJECT_DIR/requirements.txt"

# npm packages
su - vagrant -c "cd $PROJECT_DIR && npm install react react-dom"

echo "workon $VIRTUALENV_NAME" >> /home/vagrant/.bashrc

# Set execute permissions on manage.py, as they get lost if we build from a zip file
chmod a+x $PROJECT_DIR/manage.py

# Django project setup
su - vagrant -c "source $VIRTUALENV_DIR/bin/activate && cd $PROJECT_DIR && ./manage.py migrate"

# Add settings/local.py to gitignore
if ! grep -Fqx $LOCAL_SETTINGS_PATH $PROJECT_DIR/.gitignore
then
    echo $LOCAL_SETTINGS_PATH >> $PROJECT_DIR/.gitignore
fi
