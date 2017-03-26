logger -t "rc.firstboot" "Install packages eventlircd irqbalance perftune"
apt-get -q -y --allow-unauthenticated --no-install-recommends install armv7-eventlircd-kodibox armv7-irqbalance-kodibox perftune-kodibox
