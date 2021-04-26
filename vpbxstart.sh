#!/bin/bash
# This code is the property of VitalPBX LLC Company
# License: Proprietary
# Date: 25-Apr-2021
# Stop Asterisk, copy asterisk database and start Asterisk again
#
systemctl stop asterisk
/bin/cp -Rf /home/sync/var/spool/asterisk/sqlite3_temp/astdb.sqlite3 /var/lib/asterisk/astdb.sqlite3
systemctl start asterisk
