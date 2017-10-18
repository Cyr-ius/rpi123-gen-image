# set clean = false else remove flag file in bootstrap.d/flags
# set clean = true , delete all flags in bootstrap.d/flags
# -min is Debian Stretch Lite ENABLE_REDUCE=true 
# -kbox is Debian Stretch with Kodi
CLEAN ?= true

# RPI A ,A+, B, B+, 0, 0-W  config is brcm2835
# RPI 2B config is brcm2836
# RPI 3B config is brcm2837

all: rbp0w rbp1 rbp2

min: rbp0w-min rbp1-min rbp2-min

env: rbp1-env rbp2-env

kbox: rbp1-kbox rbp2-kbox

rbp0:rbp1
rbp0-min:rbp1-min	
rbp0-kbox:rbp1-kbox

rbp0w:
	sudo CLEAN=${CLEAN} \
		ENABLE_WIRELESS=true ENABLE_BLUETOOTH=true ENABLE_NONFREE=true \
		HOST_NAME=rbp0w \
		CONFIG_TEMPLATE=rpi0stretch ./rpi123-gen-image.sh
rbp0w-min:
	sudo CLEAN=${CLEAN} \
		ENABLE_WIRELESS=true ENABLE_BLUETOOTH=true ENABLE_NONFREE=true \
		ENABLE_MINBASE=true  ENABLE_REDUCE=true \
		HOST_NAME=rbp0w-min \
		CONFIG_TEMPLATE=rpi0stretch ./rpi123-gen-image.sh
rbp0w-kbox:
	sudo CLEAN=${CLEAN} \
		ENABLE_WIRELESS=true ENABLE_BLUETOOTH=true ENABLE_NONFREE=true \
		CONFIG_TEMPLATE=rpi0kbox ./rpi123-gen-image.sh

rbp1:
	sudo CLEAN=${CLEAN} \
	CONFIG_TEMPLATE=rpi1stretch ./rpi123-gen-image.sh
rbp1-min:
	sudo CLEAN=${CLEAN} \
	ENABLE_MINBASE=true ENABLE_REDUCE=true \
	HOST_NAME=rbp1-min \
	CONFIG_TEMPLATE=rpi1stretch ./rpi123-gen-image.sh
rbp1-kbox:
	sudo CLEAN=${CLEAN} \
	CONFIG_TEMPLATE=rpi1kbox ./rpi123-gen-image.sh
	
rbp2:
	sudo CLEAN=${CLEAN} \
	CONFIG_TEMPLATE=rpi2stretch ./rpi123-gen-image.sh
rbp2-min:
	sudo CLEAN=${CLEAN} \
	ENABLE_MINBASE=true ENABLE_REDUCE=true \
	HOST_NAME=rbp2-min \
	CONFIG_TEMPLATE=rpi2stretch ./rpi123-gen-image.sh
rbp2-kbox:
	sudo CLEAN=${CLEAN} \
	CONFIG_TEMPLATE=rpi2kbox ./rpi123-gen-image.sh
	
rbp3:rbp2
rbp3-min:rbp2-min
rbp3-kbox:rbp2-kbox
	
rbp3x64:
	sudo CLEAN=${CLEAN} \
	CONFIG_TEMPLATE=rpi3x64stretch ./rpi123-gen-image.sh		
rbp3x64-min:
	sudo CLEAN=${CLEAN} \
	ENABLE_MINBASE=true ENABLE_REDUCE=true \
	HOST_NAME=rbp3x64-min \
	CONFIG_TEMPLATE=rpi3x64stretch ./rpi123-gen-image.sh
rbp3x64-kbox:
	sudo CLEAN=${CLEAN} \
	CONFIG_TEMPLATE=rpi3x64kbox ./rpi123-gen-image.sh	

rbp0-env:rbp1-env
rbp0w-env:rbp1-env
rbp1-env:
	sudo bash deb-packages/rpi-userland/build.sh 1

rbp2-env:
	sudo bash deb-packages/rpi-userland/build.sh 2

rbp3-env:rbp2-env
rbp3x64-env:
	sudo bash deb-packages/rpi-userland/build.sh 3x64	

rbp0-deb:rbp1-deb
rbp0w-deb:rbp1-deb
rbp1-deb:
	sudo bash deb-packages/libcec/build.sh 1
	sudo bash deb-packages/perftune/build.sh 1
	sudo bash deb-packages/shairplay/build.sh 1
	sudo bash deb-packages/ply-lite/build.sh 1
	sudo bash deb-packages/plymouth-theme-kbox-logo/build.sh 1
	
rbp2-deb:
	sudo bash deb-packages/libcec/build.sh 2
	sudo bash deb-packages/perftune/build.sh 2
	sudo bash deb-packages/shairplay/build.sh 2
	sudo bash deb-packages/ply-lite/build.sh 2
	sudo bash deb-packages/plymouth-theme-kbox-logo/build.sh 2
	
rbp3-deb:rbp2-deb
rbp3x64-deb:
	sudo bash deb-packages/libcec/build.sh 3x64
	sudo bash deb-packages/perftune/build.sh 3x64
	sudo bash deb-packages/shairplay/build.sh 3x64
	sudo bash deb-packages/ply-lite/build.sh 3x64
	sudo bash deb-packages/plymouth-theme-kbox-logo/build.sh 3x64

clean:
	sudo rm -rf ./bootstrap.d/flags
	sudo rm -rf ./custom.d/flags
	sudo rm -rf ./images
	sudo rm -rf ./tools
	