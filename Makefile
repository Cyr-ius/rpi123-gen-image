# set clean = false else remove flag file in bootstrap.d/flags
# set clean = true , delete all flags in bootstrap.d/flags
# -min is Debian Stretch Lite ENABLE_REDUCE=true 
# -kbox is Debian Stretch with Kodi
# RPI A ,A+, B, B+, 0, 0-W  config is brcm2835
# RPI 2B config is brcm2836
# RPI 3B config is brcm2837
CLEAN ?= true
ENABLE_CAM ?= false

ifeq ($(LOCALE),fr)
	DEFLOCAL="fr_FR.UTF-8" 
	TIMEZONE="Europe/Paris" 
	XKB_MODEL="pc105" 
	XKB_LAYOUT="fr" 
	XKB_VARIANT="oss"
endif

define rbp
	sudo CLEAN=${CLEAN} DEFLOCAL=$(DEFLOCAL) TIMEZONE=$(TIMEZONE) XKB_MODEL=$(XKB_MODEL) XKB_LAYOUT=$(XKB_LAYOUT) XKB_VARIANT=$(XKB_VARIANT) \
		ENABLE_WIRELESS=$(1) ENABLE_BLUETOOTH=$(2) ENABLE_NONFREE=$(3) \
		APT_INCLUDES_KERNEL="rpi$(4)-firmware" RPI_MODEL=$(4) HOST_NAME=$@ ./rpi123-gen-image.sh
endef

define rbp-min
	sudo CLEAN=${CLEAN} DEFLOCAL=$(DEFLOCAL) TIMEZONE=$(TIMEZONE) XKB_MODEL=$(XKB_MODEL) XKB_LAYOUT=$(XKB_LAYOUT) XKB_VARIANT=$(XKB_VARIANT) \
		ENABLE_WIRELESS=$(1) ENABLE_BLUETOOTH=$(2) ENABLE_NONFREE=$(3) \
		ENABLE_MINBASE=true  ENABLE_REDUCE=true \
		APT_INCLUDES_KERNEL="rpi$(4)-firmware" RPI_MODEL=$(4) HOST_NAME=$@ ./rpi123-gen-image.sh
endef

define rbp-kbox
	sudo CLEAN=${CLEAN} DEFLOCAL=$(DEFLOCAL) TIMEZONE=$(TIMEZONE) XKB_MODEL=$(XKB_MODEL) XKB_LAYOUT=$(XKB_LAYOUT) XKB_VARIANT=$(XKB_VARIANT) \
		ENABLE_WIRELESS=$(1) ENABLE_BLUETOOTH=$(2) ENABLE_NONFREE=$(3) \
		USER_NAME="kodi" USER_PASSWORD="kodi" ENABLE_CONSOLE="false" ENABLE_INITRAMFS="true" ENABLE_SPLASHSCREEN="true" \
		ENABLE_KODI="true" ENABLE_KODI_AUTOSTART="true" ENABLE_KODI_SPLASHSCREEN="true" \
		APT_INCLUDES_KERNEL="rpi$(4)-firmware" RPI_MODEL=$(4) HOST_NAME=$@ ./rpi123-gen-image.sh
endef

all: rbp0w rbp1 rbp2
min: rbp0w-min rbp1-min rbp2-min
env: rbp1-env rbp2-env
kbox: rbp1-kbox rbp2-kbox

rbp0:rbp1
rbp0-min:rbp1-min	
rbp0-kbox:rbp1-kbox

rbp3:rbp2
rbp3-min:rbp2-min
rbp3--kbox:rbp2-kbox

rbp0w:
	$(call rbp,true,true,true,1)
rbp0w-min:
	$(call rbp-min,true,true,true,1)
rbp0w-kbox:
	$(call rbp-kbox,true,true,true,1)
rbp1:
	$(call rbp,false,false,false,1)
rbp1-min:
	$(call rbp-min,false,false,false,1)
rbp1-kbox:
	$(call rbp-kbox,false,false,false,1)
rbp2:
	$(call rbp,false,false,false,2)
rbp2-min:
	$(call rbp-min,false,false,false,2)
rbp2-kbox:
	$(call rbp-kbox,false,false,false,2)
rbp3x64:
	$(call rbp,false,false,false,3x64)
rbp3x64-min:
	$(call rbp-min,false,false,false,3x64)
rbp3x64-kbox:
	$(call rbp-kbox,false,false,false,3x64)
	
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
	sudo bash deb-packages/perftune/build.sh 1
	sudo bash deb-packages/ply-lite/build.sh 1
	sudo bash deb-packages/plymouth-theme-kbox-logo/build.sh 1
	sudo bash deb-packages/pi-bluetooth/build.sh 1
	sudo bash deb-packages/kodi-autostart/build.sh 1
	sudo bash deb-packages/libcec/build.sh 1
	sudo bash deb-packages/shairplay/build.sh 1
	
rbp2-deb:
	sudo bash deb-packages/perftune/build.sh 2
	sudo bash deb-packages/ply-lite/build.sh 2
	sudo bash deb-packages/plymouth-theme-kbox-logo/build.sh 2
	sudo bash deb-packages/pi-bluetooth/build.sh 2
	sudo bash deb-packages/kodi-autostart/build.sh 2
	sudo bash deb-packages/libcec/build.sh 2
	sudo bash deb-packages/shairplay/build.sh 2	
	
rbp3-deb:rbp2-deb
rbp3x64-deb:
	sudo bash deb-packages/perftune/build.sh 3x64
	sudo bash deb-packages/ply-lite/build.sh 3x64
	sudo bash deb-packages/plymouth-theme-kbox-logo/build.sh 3x64
	sudo bash deb-packages/pi-bluetooth/build.sh 3x64
	sudo bash deb-packages/kodi-autostart/build.sh 3x64
	sudo bash deb-packages/libcec/build.sh 3x64
	sudo bash deb-packages/shairplay/build.sh 3x64	

clean:
	sudo rm -rf ./bootstrap.d/flags
	sudo rm -rf ./custom.d/flags
	sudo rm -rf ./images
	sudo rm -rf ./tools
	