#!/bin/bash

if [ ! -f ${NAGIOS_HOME}/etc/htpasswd.users ] ; then
  htpasswd -c -b -s ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS}
  chown -R nagios.nagios ${NAGIOS_HOME}/etc/htpasswd.users
fi

/etc/init.d/mysql start
/etc/init.d/apache2 start
/etc/init.d/xinetd restart