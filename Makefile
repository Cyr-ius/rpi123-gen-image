all: rbp rbp2 rbp3_64
	@echo "Specify a target:\nmake kernel\nmake userland\nmake raspiconfig\nmake combine"
	
rbp1_kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi1kbox ./rpi123-gen-image.sh

rbp2_kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi2kbox ./rpi123-gen-image.sh
	
rbp3_kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi3kbox ./rpi123-gen-image.sh	
	
rbp3_64_kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi3_64kbox ./rpi123-gen-image.sh	
	
rbp1-env:
	sudo bash deb-packages/kbox-kernel/build.sh rbp
	sudo bash deb-packages/kbox-userland/build.sh rbp

rbp2-env:
	sudo bash deb-packages/kbox-kernel/build.sh rbp2
	sudo bash deb-packages/kbox-userland/build.sh rbp2

rbp3-env:
	sudo bash deb-packages/kbox-kernel/build.sh rbp3
	sudo bash deb-packages/kbox-userland/build.sh rbp3
	
rbp3_64-env:
	sudo bash deb-packages/kbox-kernel/build.sh rbp3_64
	sudo bash deb-packages/kbox-userland/build.sh rbp3_64	

rbp1:rbp1-env
	sudo bash deb-packages/kbox-raspi-config/build.sh rbp
	sudo bash deb-packages/kbox-perftune/build.sh rbp
	sudo bash deb-packages/kbox-libshairplay/build.sh rbp
	sudo bash deb-packages/kbox-splashscreen/build.sh rbp
	sudo bash deb-packages/kbox-ply-lite/build.sh rbp
	sudo bash deb-packages/kbox-arm-mem/build.sh rbp	
	
rbp2:rbp2-env
	sudo bash deb-packages/kbox-raspi-config/build.sh rbp2
	sudo bash deb-packages/kbox-perftune/build.sh rbp2
	sudo bash deb-packages/kbox-libshairplay/build.sh rbp2
	sudo bash deb-packages/kbox-splashscreen/build.sh rbp2
	sudo bash deb-packages/kbox-ply-lite/build.sh rbp2
	sudo bash deb-packages/kbox-arm-mem/build.sh rbp2
	
rbp3:rbp3-env
	sudo bash deb-packages/kbox-raspi-config/build.sh rbp3
	sudo bash deb-packages/kbox-perftune/build.sh rbp3
	sudo bash deb-packages/kbox-libshairplay/build.sh rbp3
	sudo bash deb-packages/kbox-splashscreen/build.sh rbp3
	sudo bash deb-packages/kbox-ply-lite/build.sh rbp3
	sudo bash deb-packages/kbox-arm-mem/build.sh rbp3	

rbp3_64:rbp3_64-env
	sudo bash deb-packages/kbox-raspi-config/build.sh rbp3_64
	sudo bash deb-packages/kbox-perftune/build.sh rbp3_64
	sudo bash deb-packages/kbox/bootstrap.d/flags-libshairplay/build.sh rbp3_64
	sudo bash deb-packages/kbox-splashscreen/build.sh rbp3_64
	sudo bash deb-packages/kbox-ply-lite/build.sh rbp3_64
	sudo bash deb-packages/kbox-arm-mem/build.sh rbp3_64	

clean:
	sudo rm -rf ./bootstrap.d/flags
	sudo rm -rf ./custom.d/flags
	sudo rm -rf ./firmware
	sudo rm -rf ./images
	sudo rm -rf ./linux
	sudo rm -rf ./tools
	