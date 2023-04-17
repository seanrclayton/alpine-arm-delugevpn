#FROM alpine:latest as builder
FROM alpine:3.15.5 as builder
# additional files
##################

RUN apk add bash curl python3 py3-pip moreutils grep supervisor openvpn drill dumb-init tini jq coreutils

ADD build/supervisor.conf /etc/

# grabbed from his github repo:
# curl --connect-timeout 5 --max-time 600 --retry 5 --retry-delay 0 --retry-max-time 60 -o /tmp/scripts-master.zip -L https://github.com/binhex/scripts/archive/master.zip
ADD build/docker/*.sh /usr/local/bin/


# add install bash script
ADD build/root/*.sh /root/

# add bash script to run openvpn
ADD run/root/*.sh /root/

# add bash script to run privoxy
ADD run/nobody/*.sh /home/nobody/

# docker settings
#################

# expose port for privoxy
EXPOSE 8118


FROM builder

RUN apk add libtorrent-rasterbar openssl py3-chardet py3-dbus py3-distro py3-idna py3-mako py3-pillow py3-openssl py3-rencode py3-service_identity py3-setproctitle py3-six py3-future py3-requests py3-twisted py3-xdg py3-zope-interface xdg-utils libappindicator deluge
RUN pip3 install python-geoip-python3



# add supervisor conf file for app
ADD build/*.conf /etc/supervisor/conf.d/

# add bash scripts to install app
ADD build/root/*.sh /root/

# get release tag name from build arg
## not using right now to reduce complexity.
#ARG release_tag_name

# add bash script to run deluge
ADD run/nobody/*.sh /home/nobody/

# add python script to configure deluge
ADD run/nobody/*.py /home/nobody/

# add pre-configured config files for deluge
ADD config/nobody/ /home/nobody/

# install app
#############



# docker settings
#################


# expose port for deluge webui
EXPOSE 8112

# expose port for privoxy
EXPOSE 8118

# expose port for deluge daemon (used in conjunction with LAN_NETWORK env var)
EXPOSE 58846

# expose port for deluge incoming port (used only if VPN_ENABLED=no)
EXPOSE 58946
EXPOSE 58946/udp



ENTRYPOINT ["/usr/bin/dumb-init", "--"]


# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh /home/nobody/*.sh /home/nobody/*.py && \
	/bin/bash /root/install.sh "0.1"

# run script to set uid, gid and permissions
CMD ["/bin/bash", "/usr/local/bin/init.sh"]
