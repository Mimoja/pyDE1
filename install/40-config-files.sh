#!/usr/bin/sh -e

# Copyright © 2021 Jeff Kletsky. All Rights Reserved.
#
# License for this software, part of the pyDE1 package, is granted under
# GNU General Public License v3.0 only
# SPDX-License-Identifier: GPL-3.0-only

. "$(dirname $0)"/_config

. $VENV_PATH/bin/activate

PYDE1_ROOT=$(python -c \
  'import importlib.resources ; print(importlib.resources.files("pyDE1"))')

mkdir -p /usr/local/etc/pyde1

CP_BACKUP="cp -v --backup --suffix=$(date +'.%Y%m%d_%H%M')"

$CP_BACKUP ${PYDE1_ROOT}/services/config/* /usr/local/etc/pyde1/

# As the config files may contain credentials,
# make them unreadable to anyone but root and pyde1

chown root:${PYDE1_GROUP} /usr/local/etc/pyde1/*
chmod 640 /usr/local/etc/pyde1/*

$CP_BACKUP ${PYDE1_ROOT}/services/unit-files/* /usr/local/etc/pyde1/
chown root:root /usr/local/etc/pyde1/*.service
chmod 644 /usr/local/etc/pyde1/*.service

for f in /usr/local/etc/pyde1/*.service ; do
  # This is rather fragile. TODO: Consider a template
  sed -i'.bak'  \
    -e "s|^User=.*|User=${PYDE1_USER}|" \
    -e "s|^Group=.*|Group=${PYDE1_GROUP}|" \
    -e "s|^Environment=\"PYDE1_PATH.*$|Environment=\"PYDE1_PATH=${PYDE1_ROOT}\"|" \
    -e "s|^Environment=\"PYTHONPATH.*$||" \
    -e "s|^ExecStart=/home/pyde1/venv/pyde1|ExecStart=${VENV_PATH}|" \
    $f
done

ls -l /usr/local/etc/*
