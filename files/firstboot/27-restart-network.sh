# Restart Network services
logger -t "rc.firstboot" "Reload systemd manager configuration"
systemctl daemon-reload
systemctl restart networking.service
systemctl restart systemd-networkd.service
