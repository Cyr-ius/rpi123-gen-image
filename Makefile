# set clean = false else remove flag file in bootstrap.d/flags
# set clean = true , delete all flags in bootstrap.d/flags
# -min is Debian Stretch Lite ENABLE_REDUCE=true 
# -kbox is Debian Stretch with Kodi
# RPI A ,A+, B, B+, 0, 0-W  config is brcm2835
# RPI 2B config is brcm2836
# RPI 3B config is brcm2837
LOCALE ?= true
RPI_MODEL ?= 2
GENERIC_OPTIONS=ENABLE_IPOCUS=true ENABLE_RASPBERRYPI=true ENABLE_RASPBIAN=true RPI_MODEL=$(RPI_MODEL) APT_INCLUDES_KERNEL="rbpi$(RPI_MODEL)-firmware" HOST_NAME=$(HOST_NAME)

ifeq ($(MIN),true)
	GENERIC_OPTIONS:=ENABLE_MINBASE=true ENABLE_REDUCE=true $(GENERIC_OPTIONS)
endif

ifeq ($(KODI),true)
	GENERIC_OPTIONS:=USER_NAME=kodi USER_PASSWORD=kodi ENABLE_CONSOLE=false ENABLE_INITRAMFS=true ENABLE_KODI=true ENABLE_KODI_AUTOSTART=true ENABLE_KODI_SPLASHSCREEN=true $(GENERIC_OPTIONS)
endif

ifeq ($(WB),true)
	GENERIC_OPTIONS:=ENABLE_WIRELESS=true ENABLE_BLUETOOTH=true ENABLE_NONFREE=true $(GENERIC_OPTIONS)
endif

ifeq ($(LOCALE),true)
	GENERIC_OPTIONS:=DEFLOCAL=fr_FR.UTF-8 TIMEZONE=Europe/Paris XKB_MODEL=pc105 XKB_LAYOUT=fr XKB_VARIANT=oss $(GENERIC_OPTIONS)
endif

ifeq ($(CLEAN),false)
	GENERIC_OPTIONS:=CLEAN=false $(GENERIC_OPTIONS)
endif

ifeq ($(CUSTO),true)
	GENERIC_OPTIONS:=ENABLE_CUSTOMIZE=true RELEASE=stretch $(GENERIC_OPTIONS)
endif

ifeq ($(CAM),true)
	GENERIC_OPTIONS:=ENABLE_CAMERA=true $(GENERIC_OPTIONS)
endif

.build:
	sudo $(GENERIC_OPTIONS) ./rpi123-gen-image.sh

all: rbpi0w rbpi1 rbpi2
min: rbpi0w-min rbpi1-min rbpi2-min
kbox: rbpi1-kbox rbpi2-kbox
custo: rbpi1-custo rbpi2-custo

rbpi0:rbpi1
rbpi0-min:rbpi1-min	
rbpi0-kbox:rbpi1-kbox

rbpi0w:
	RPI_MODEL=1 HOST_NAME=$@ WB=true $(MAKE) .build
rbpi0w-min:
	RPI_MODEL=1 HOST_NAME=$@ WB=true MIN=true $(MAKE) .build
rbpi0w-kbox:
	RPI_MODEL=1 HOST_NAME=$@ WB=true KODI=true $(MAKE) .build
rbpi0w-cam:
	RPI_MODEL=1 HOST_NAME=pi-cam WB=true MIN=true CUSTO=true CAM=true $(MAKE) .build

rbpi1:
	RPI_MODEL=1 HOST_NAME=$@ $(MAKE) .build
rbpi1-min:
	RPI_MODEL=1 HOST_NAME=$@ MIN=true $(MAKE) .build
rbpi1-kbox:
	RPI_MODEL=1 HOST_NAME=$@ KODI=true $(MAKE) .build
rbpi1-custo:
	RPI_MODEL=1 HOST_NAME=alfred KODI=true CUSTO=true LOCALE=true $(MAKE) .build

rbpi2:
	RPI_MODEL=2 HOST_NAME=$@ $(MAKE) .build
rbpi2-min:
	RPI_MODEL=2 HOST_NAME=$@ MIN=true $(MAKE) .build
rbpi2-kbox:
	RPI_MODEL=2 HOST_NAME=$@ KODI=true $(MAKE) .build
rbpi2-custo:
	RPI_MODEL=2 HOST_NAME=alfred KODI=true CUSTO=true LOCALE=true $(MAKE) .build

rbpi3:
	RPI_MODEL=2 HOST_NAME=$@ WB=true $(MAKE) .build
rbpi3-min:
	RPI_MODEL=2 HOST_NAME=$@ MIN=true WB=true $(MAKE) .build
rbpi3-kbox:
	RPI_MODEL=2 HOST_NAME=$@ KODI=true WB=true $(MAKE) .build
rbpi3-custo:
	RPI_MODEL=2 HOST_NAME=alfred KODI=true CUSTO=true LOCALE=true WB=true $(MAKE) .build

rbpi3x64:
	RPI_MODEL=3x64 HOST_NAME=$@ $(MAKE) .build
rbpi3x64-min:
	RPI_MODEL=3x64 HOST_NAME=$@ MIN=true $(MAKE) .build
rbpi3x64-kbox:
	RPI_MODEL=3x64 HOST_NAME=$@ KODI=true $(MAKE) .build

clean:
	sudo rm -rf bootstrap.d/flags
	sudo rm -rf custom.d/flags
	sudo rm -rf images
