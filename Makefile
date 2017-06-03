all: rbp rbp2
	@echo "Specify a target:\nmake kernel\nmake userland\nmake raspiconfig\nmake combine"
	
rbp1-env:
	sudo bash deb-packages/kbox-kernel/rpi123-gen-image.sh rbp
	sudo bash deb-packages/kbox-userland/rpi123-gen-image.sh rbp

rbp2-env:
	sudo bash deb-packages/kbox-kernel/rpi123-gen-image.sh rbp2
	sudo bash deb-packages/kbox-userland/rpi123-gen-image.sh rbp2

rbp3-env:
	sudo bash deb-packages/kbox-kernel/rpi123-gen-image.sh rbp3
	sudo bash deb-packages/kbox-userland/rpi123-gen-image.sh rbp3
	
rbp3_64-env:
	sudo bash deb-packages/kbox-kernel/rpi123-gen-image.sh rbp3_64
	sudo bash deb-packages/kbox-userland/rpi123-gen-image.sh rbp3_64	

rbp1:
	sudo bash deb-packages/kbox-raspi-config/rpi123-gen-image.sh rbp
	sudo bash deb-packages/kbox-perftune/rpi123-gen-image.sh rbp
	sudo bash deb-packages/kbox-libshairplay/rpi123-gen-image.sh rbp
	sudo bash deb-packages/kbox-splashscreen/rpi123-gen-image.sh rbp
	sudo bash deb-packages/kbox-kernel/rpi123-gen-image.sh rbp
	sudo bash deb-packages/kbox-userland/rpi123-gen-image.sh rbp
	
rbp2:
	sudo bash deb-packages/kbox-raspi-config/rpi123-gen-image.sh rbp2
	sudo bash deb-packages/kbox-perftune/rpi123-gen-image.sh rbp2
	sudo bash deb-packages/kbox-libshairplay/rpi123-gen-image.sh rbp2
	sudo bash deb-packages/kbox-splashscreen/rpi123-gen-image.sh rbp2
	sudo bash deb-packages/kbox-kernel/rpi123-gen-image.sh rbp2
	sudo bash deb-packages/kbox-userland/rpi123-gen-image.sh rbp2
	
rbp3:
	sudo bash deb-packages/kbox-raspi-config/rpi123-gen-image.sh rbp3
	sudo bash deb-packages/kbox-perftune/rpi123-gen-image.sh rbp3
	sudo bash deb-packages/kbox-libshairplay/rpi123-gen-image.sh rbp3
	sudo bash deb-packages/kbox-splashscreen/rpi123-gen-image.sh rbp3
	sudo bash deb-packages/kbox-kernel/rpi123-gen-image.sh rbp3	
	sudo bash deb-packages/kbox-userland/rpi123-gen-image.sh rbp3

rbp3_64:
	sudo bash deb-packages/kbox-raspi-config/rpi123-gen-image.sh rbp3_64
	sudo bash deb-packages/kbox-perftune/rpi123-gen-image.sh rbp3_64
	sudo bash deb-packages/kbox-libshairplay/rpi123-gen-image.sh rbp3_64
	sudo bash deb-packages/kbox-splashscreen/rpi123-gen-image.sh rbp3_64
	sudo bash deb-packages/kbox-kernel/rpi123-gen-image.sh rbp3_64
	sudo bash deb-packages/kbox-userland/rpi123-gen-image.sh rbp3_64
	
rbp1_kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi1kbox ./rpi123-gen-image.sh

rbp2_kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi2kbox ./rpi123-gen-image.sh
	
rbp3_kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi3kbox ./rpi123-gen-image.sh	
	
rbp3_64_kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi3_64kbox ./rpi123-gen-image.sh	
