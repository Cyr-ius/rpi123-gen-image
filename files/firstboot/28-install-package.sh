logger -t "rc.firstboot" "Install packages perftune"
apt-get -qq -y update
apt-get -q -y --allow-unauthenticated --no-install-recommends install kbox-perftune systemd-sysv
