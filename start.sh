#!/bin/bash

if [ ! -f ${NAGIOS_HOME}/etc/htpasswd.users ] ; then
  htpasswd -c -b -s ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS}
  chown -R nagios.nagios ${NAGIOS_HOME}/etc/htpasswd.users
fi

/etc/init.d/mysql restart
/etc/init.d/apache2 restart
/etc/init.d/xinetd restart
/etc/init.d/nagios restart
