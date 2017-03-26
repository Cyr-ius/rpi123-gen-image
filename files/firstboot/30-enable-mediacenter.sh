logger -t "rc.firstboot" "Enable and start mediacenter.service"
systemctl enable mediacenter.service
systemctl start mediacenter.service
