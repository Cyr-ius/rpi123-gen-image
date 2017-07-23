all: rbp0w rbp1 rbp2 rbp1-kbox rbp2-kbox
	@echo "Specify a target:\nmake kernel\nmake userland\nmake raspiconfig\nmake combine"
	
rbp0-kbox:rbp1-kbox

rbp0w-kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi0wkbox ./rpi123-gen-image.sh
	
rbp1-kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi1kbox ./rpi123-gen-image.sh

rbp2-kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi2kbox ./rpi123-gen-image.sh
	
rbp3-kbox:rbp2-kbox
	
rbp3x64-kbox:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi3x64kbox ./rpi123-gen-image.sh	

rbp0:rbp1
	
rbp0-min:rbp1-min	

rbp0w:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi0wstretch ./rpi123-gen-image.sh
	
rbp0w-min:
	sudo ENABLE_MINBASE=true ENABLE_REDUCE=true CLEAN=true HOST_NAME=rbp0w-min CONFIG_TEMPLATE=rpi0wstretch ./rpi123-gen-image.sh		

rbp1:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi1stretch ./rpi123-gen-image.sh
	
rbp1-min:
	sudo ENABLE_MINBASE=true ENABLE_REDUCE=true CLEAN=true HOST_NAME=rbp1-min CONFIG_TEMPLATE=rpi1stretch ./rpi123-gen-image.sh	
	
rbp2:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi2stretch ./rpi123-gen-image.sh
	
rbp2-min:
	sudo ENABLE_MINBASE=true ENABLE_REDUCE=true CLEAN=true HOST_NAME=rbp2-min CONFIG_TEMPLATE=rpi2stretch ./rpi123-gen-image.sh		
	
rbp3:rbp2

rbp3-min:rbp2-min
	
rbp3x64:
	sudo CLEAN=true CONFIG_TEMPLATE=rpi3x64stretch ./rpi123-gen-image.sh		
	
rbp3x64-min:
	sudo ENABLE_MINBASE=true ENABLE_REDUCE=true CLEAN=true HOST_NAME=rbp3x64-min CONFIG_TEMPLATE=rpi3x64stretch ./rpi123-gen-image.sh	

rbp0-env:rbp1-env
	
rbp1-env:
	sudo bash deb-packages/kbox-userland/build.sh 1

rbp2-env:
	sudo bash deb-packages/kbox-userland/build.sh 2

rbp3-env:rbp2-env

rbp3x64-env:
	sudo bash deb-packages/kbox-userland/build.sh 3x64	

rbp0-deb:rbp1-deb

rbp1-deb:rbp1-env
	sudo bash deb-packages/kbox-raspi-config/build.sh 1
	sudo bash deb-packages/kbox-perftune/build.sh 1
	sudo bash deb-packages/kbox-libshairplay/build.sh 1
	sudo bash deb-packages/kbox-splashscreen/build.sh 1
	sudo bash deb-packages/kbox-ply-lite/build.sh 1
	sudo bash deb-packages/kbox-arm-mem/build.sh 1
	
rbp2-deb:rbp2-env
	sudo bash deb-packages/kbox-raspi-config/build.sh 2
	sudo bash deb-packages/kbox-perftune/build.sh 2
	sudo bash deb-packages/kbox-libshairplay/build.sh 2
	sudo bash deb-packages/kbox-splashscreen/build.sh 2
	sudo bash deb-packages/kbox-ply-lite/build.sh 2
	sudo bash deb-packages/kbox-arm-mem/build.sh 2
	
rbp3-deb:rbp2-deb

rbp3x64-deb:rbp3x64-env
	sudo bash deb-packages/kbox-raspi-config/build.sh 3x64
	sudo bash deb-packages/kbox-perftune/build.sh 3x64
	sudo bash deb-packages/kbox/bootstrap.d/flags-libshairplay/build.sh 3x64
	sudo bash deb-packages/kbox-splashscreen/build.sh 3x64
	sudo bash deb-packages/kbox-ply-lite/build.sh 3x64
	sudo bash deb-packages/kbox-arm-mem/build.sh 3x64	

clean:
	sudo rm -rf ./bootstrap.d/flags
	sudo rm -rf ./custom.d/flags
	sudo rm -rf ./images
	sudo rm -rf ./tools
	