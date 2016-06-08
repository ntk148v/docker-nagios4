FROM ntk148v/lamp-server:v1
ENV NAGIOS_HOME /usr/local/nagios/
ENV NAGIOS_USER nagios
ENV NAGIOS_GROUP nagios
ENV NAGIOS_CMDUSER nagios
ENV NAGIOS_CMDGROUP nagcmd
ENV NAGIOSADMIN_USER nagiosadmin
ENV NAGIOSADMIN_PASS nagios
ENV APACHE_RUN_USER nagios
ENV APACHE_RUN_GROUP nagios
ENV NAGIOS_TIMEZONE UTC
ENV APACHE_LOCK_DIR /var/run
ENV APACHE_LOG_DIR /var/log/apache2

RUN apt-get update
RUN ( egrep -i  "^${NAGIOS_GROUP}" /etc/group || groupadd $NAGIOS_GROUP ) && ( egrep -i "^${NAGIOS_CMDGROUP}" /etc/group || groupadd $NAGIOS_CMDGROUP )
RUN ( id -u $NAGIOS_USER || useradd --system $NAGIOS_USER -g $NAGIOS_GROUP) && ( id -u $NAGIOS_CMDUSER || useradd -g $NAGIOS_CMDGROUP $NAGIOS_CMDUSER )
RUN apt-get -y install build-essential \
					   libgd2-xpm-dev \ 
					   openssl \
					   libssl-dev \ 
					   xinetd \
					   apache2-utils \
					   unzip
WORKDIR /opt/
RUN wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz \
	&& tar -xvf nagios-4.1.1.tar.gz
WORKDIR /opt/nagios-4.1.1/
RUN	./configure -with-nagios-command-user=${NAGIOS_CMDUSER} --with-command-group=${NAGIOS_CMDGROUP} \ 
	--with-nagios-user=${NAGIOS_USER} --with-nagios-group=${NAGIOS_GROUP} \
	&& make all \
	&& make install \
	&& make install-init \
	&& make install-config \
	&& make install-commandmode
WORKDIR /opt/
RUN wget http://www.nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz \
	&& tar -xvf nagios-plugins-2.1.1.tar.gz
WORKDIR /opt/nagios-plugins-2.1.1/
RUN ./configure --with-nagios-user=${NAGIOS_USER} --with-nagios-group=${NAGIOS_GROUP} --with-openssl \
	&& make \
	&& make install
WORKDIR /opt/
RUN wget http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz \
	&& tar -xvf nrpe-2.15.tar.gz
WORKDIR /opt/nrpe-2.15/
RUN ./configure --enable-command-args --with-nagios-user=${NAGIOS_USER} --with-nagios-group=${NAGIOS_GROUP} \ 
	--with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu \
	&& make all \
	&& make install \
	&& make install-xinetd \
	make install-daemon-config
RUN service xinetd restart
RUN echo "cfg_dir=${NAGIOS_HOME}etc/servers" >> ${NAGIOS_HOME}etc/nagios.cfg
ADD nagios.conf /etc/apache2/conf-available/nagios.conf
RUN usermod -G nagcmd www-data
RUN a2enconf nagios && a2enmod cgi && service apache2 restart
RUN /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
RUn service nagios start
RUN ln -s /etc/init.d/nagios /etc/rcS.d/S99

ADD start.sh /opt/
RUN chmod 755 /opt/start.sh
RUN /opt/start.sh

EXPOSE 80
