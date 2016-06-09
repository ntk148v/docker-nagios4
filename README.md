# Nagios 4 with Docker

## Usage

1. First, you have to define your server's ip, which one you want to monitor. In this case, it is OBM Server's ip in `obm.cfg`.
2. Second, build Docker image with Dockfile.
3. Third, run Docker container. When you access to this container, you have to run `/tmp/start.sh`, then define Nagios Server's Ip in `/etc/xinetd.d/nrpe`. Find `only_from = ` line then fill ip:

```
    # default: on
    # description: NRPE (Nagios Remote Plugin Executor)
    service nrpe
    {
            flags           = REUSE
            socket_type     = stream
            port            = 5666
            wait            = no
            user            = nagios
            group           = nagios
            server          = /usr/local/nagios/bin/nrpe
            server_args     = -c /usr/local/nagios/etc/nrpe.cfg --inetd
            log_on_failure  += USERID
            disable         = no
            only_from       = 127.0.0.1 <nagios_server_private_ip>
    }
```
4. Finally, restart xinet service.