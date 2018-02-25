# set clean = false else remove flag file in bootstrap.d/flags
# set clean = true , delete all flags in bootstrap.d/flags
# -min is Debian Stretch Lite ENABLE_REDUCE=true 
# -kbox is Debian Stretch with Kodi
# RPI A ,A+, B, B+, 0, 0-W  config is brcm2835
# RPI 2B config is brcm2836
# RPI 3B config is brcm2837
CLEAN ?= true
ENABLE_CUSTOMIZE ?= false
LOCALE ?= true
RPI_MODEL ?= 2

ifeq ($(MIN),true)
	MIN:=ENABLE_MINBASE=true  ENABLE_REDUCE=true
endif

ifeq ($(KODI),true)
	KODI:=USER_NAME=kodi USER_PASSWORD=kodi ENABLE_CONSOLE=false ENABLE_INITRAMFS=true ENABLE_SPLASHSCREEN=true ENABLE_KODI=true ENABLE_KODI_AUTOSTART=true ENABLE_KODI_SPLASHSCREEN=true
endif

ifeq ($(WB),true)
	WB:=ENABLE_WIRELESS=true ENABLE_BLUETOOTH=true ENABLE_NONFREE=true
endif

ifeq ($(LOCALE),true)
	LOCALE:=DEFLOCAL=fr_FR.UTF-8 TIMEZONE=Europe/Paris XKB_MODEL=pc105 XKB_LAYOUT=fr XKB_VARIANT=oss
endif

.build:
	sudo CLEAN=$(CLEAN) ENABLE_CUSTOMIZE=$(ENABLE_CUSTOMIZE) $(LOCALE) $(WB) $(KODI) RPI_MODEL=$(RPI_MODEL) APT_INCLUDES_KERNEL="rpi$(RPI_MODEL)-firmware" HOST_NAME=$(HOST_NAME) ./rpi123-gen-image.sh

all: rbp0w rbp1 rbp2
min: rbp0w-min rbp1-min rbp2-min
kbox: rbp1-kbox rbp2-kbox

rbp0:rbp1
rbp0-min:rbp1-min	
rbp0-kbox:rbp1-kbox

rbp3:rbp2
rbp3-min:rbp2-min
rbp3--kbox:rbp2-kbox

rbp0w:
	RPI_MODEL=1 HOST_NAME=$@ WB=true $(MAKE) .build
rbp0w-min:
	RPI_MODEL=1 HOST_NAME=$@ WB=true MIN=true $(MAKE) .build
rbp0w-kbox:
	RPI_MODEL=1 HOST_NAME=$@ WB=true KODI=true $(MAKE) .build
rbp1:
	RPI_MODEL=1 HOST_NAME=$@ $(MAKE) .build
rbp1-min:
	RPI_MODEL=1 HOST_NAME=$@ MIN=true $(MAKE) .build
rbp1-kbox:
	RPI_MODEL=1 HOST_NAME=$@ KODI=true $(MAKE) .build
rbp2:
	RPI_MODEL=2 HOST_NAME=$@ $(MAKE) .build
rbp2-min:
	RPI_MODEL=2 HOST_NAME=$@ $(MAKE) .build
rbp2-kbox:
	RPI_MODEL=2 HOST_NAME=$@ KODI=true $(MAKE) .build
rbp3x64:
	RPI_MODEL=3x64 HOST_NAME=$@ $(MAKE) .build
rbp3x64-min:
	RPI_MODEL=3x64 HOST_NAME=$@ MIN=true $(MAKE) .build
rbp3x64-kbox:
	RPI_MODEL=3x64 HOST_NAME=$@ KODI=true $(MAKE) .build

clean:
	sudo rm -rf bootstrap.d/flags
	sudo rm -rf custom.d/flags
	sudo rm -rf images
	sudo rm -rf tools
	