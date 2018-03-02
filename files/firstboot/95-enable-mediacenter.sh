# Enable Service for execute Kodi at the system startup
logger -t "rc.firstboot" "Enable and start mediacenter.service"
systemctl enable mediacenter.service
systemctl start mediacenter.service
