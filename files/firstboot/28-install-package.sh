logger -t "rc.firstboot" "Install packages eventlircd irqbalance perftune"
apt-get -q -y --allow-unauthenticated --no-install-recommends install perftune-kodibox systemd-sysv
