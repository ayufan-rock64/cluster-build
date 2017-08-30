KERNEL_DEFCONFIG ?= rockchip_linux_defconfig

all: image

gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu:
	curl -L https://releases.linaro.org/components/toolchain/binaries/latest/aarch64-linux-gnu/$@.tar.xz | \
		tar Jx

arm-trusted-firmware:
	git clone https://github.com/ARM-software/arm-trusted-firmware.git

rkbin:
	git clone https://github.com/rockchip-linux/rkbin

u-boot:
	git clone https://github.com/ayufan-rock64/linux-u-boot u-boot -b mainline-master

kernel:
	git clone https://github.com/ayufan-rock64/linux-mainline-kernel kernel

rkbin/rk33/bl31.bin: arm-trusted-firmware gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu
	make -C $< CROSS_COMPILE="$(CURDIR)/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-" PLAT=rk3328 bl31
	cp $</build/rk3328/release/bl31.bin $@

image/rk3328evb-trust.img: # rkbin/rk33/bl31.bin
	rkbin/tools/trust_merger blobs/rk3328trust.ini

image/rk3328evb-miniloader.img:
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | dd of=miniloader.tmp bs=4 skip=1
	u-boot/tools/mkimage -n rk3328 -T rksd -d miniloader.tmp $@.tmp
	cat rkbin/rk33/rk3328_miniloader*.bin >> $@.tmp
	mv $@.tmp $@
	rm miniloader.tmp

u-boot/.config: u-boot/configs/rock64-rk3328_defconfig
	make -C u-boot rock64-rk3328_defconfig

ifeq ($(FORCE), 1)
.PHONY: u-boot/u-boot-dtb.bin
endif
u-boot/u-boot-dtb.bin: u-boot/.config
	make -C u-boot CROSS_COMPILE="ccache aarch64-linux-gnu-" DEBUG=$(DEBUG) all -j4

kernel/.config: kernel/arch/arm64/configs/$(KERNEL_DEFCONFIG)
	make -C kernel $(KERNEL_DEFCONFIG) ARCH=arm64

ifeq ($(FORCE), 1)
.PHONY: image/kernel-arm64
endif
image/kernel-arm64: kernel/.config
	make -C kernel Image ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" -j4
	cp kernel/arch/arm64/boot/Image $@

image/dtbs/rockchip/rk3328-rock64.dtb: kernel/arch/arm64/boot/dts/rockchip/rk3328-rock64.dts kernel/arch/arm64/boot/dts/rockchip/rk3328.dtsi
	make -C kernel dtbs ARCH=arm64 CROSS_COMPILE="ccache aarch64-linux-gnu-" -j4
	make -C kernel dtbs_install ARCH=arm64 INSTALL_DTBS_PATH=$(CURDIR)/image/dtbs

.PHONY: kernel-build
kernel-build: image/kernel

image/rk3328evb-uboot.bin: u-boot/u-boot-dtb.bin
	rkbin/tools/loaderimage --pack --uboot $< $@

.PHONY: u-boot-build
u-boot-build: image/rk3328evb-uboot.bin

image/pxelinux.cfg/%: blobs/pxelinux.cfg/%
	mkdir -p image/pxelinux.cfg
	cp $< $@

image/extlinux/extlinux.conf: blobs/pxelinux.cfg/default-arm-rockchip
	mkdir -p image/extlinux
	cp $< $@

image/coreos-initrd-arm64.img.gz:
	wget -O $@.tmp https://alpha.release.core-os.net/arm64-usr/current/coreos_production_pxe_image.cpio.gz
	mv $@.tmp $@

image/coreos-complete-initrd-arm64.img.gz: bootengine.cpio.gz image/coreos-initrd-arm64.img.gz
	cat $^ > $@.tmp
	mv $@.tmp $@

tmp/alpine-minirootfs-3.6.2-aarch64.tar.gz:
	mkdir -p tmp/alpine-initrd
	wget -O $@.tmp http://dl-cdn.alpinelinux.org/alpine/v3.6/releases/aarch64/alpine-minirootfs-3.6.2-aarch64.tar.gz
	mv $@.tmp $@

tmp/alpine-initrd: tmp/alpine-minirootfs-3.6.2-aarch64.tar.gz
	mkdir -p tmp/alpine-initrd
	sudo tar -zxf $< -C $@
	sudo chmod 755 tmp/alpine-initrd
	sudo touch $@

ifeq ($(FORCE), 1)
.PHONY: image/alpine-initrd-arm64.img.gz
endif
image/alpine-initrd-arm64.img.gz: tmp/alpine-initrd
	sudo cp /usr/bin/qemu-aarch64-static tmp/alpine-initrd/usr/bin/
	sudo cp /etc/resolv.conf tmp/alpine-initrd/etc/
	# sudo chroot tmp/alpine-initrd apk add openrc --no-cache
	# sudo rm -f tmp/alpine-initrd/{usr/bin/qemu-aarch64-static,etc/resolv.conf}
	( cd tmp/alpine-initrd && sudo find . | sudo cpio -o -H newc ) | gzip -c > $@.tmp
	mv $@.tmp $@

.PHONY: alpine-initrd
alpine-initrd: image/alpine-initrd-arm64.img.gz

image/bootengine.cpio.gz: bootengine.cpio.gz
	cp $< $@

image: image/rk3328evb-trust.img \
	image/rk3328evb-uboot.bin \
	image/rk3328evb-miniloader.img \
	image/kernel-arm64 \
	image/dtbs/rockchip/rk3328-rock64.dtb \
	image/alpine-initrd-arm64.img.gz \
	image/pxelinux.cfg/default-arm-rockchip \
	image/extlinux/extlinux.conf

run: image
	rkflashtool/rkflashloader rk3328evb

.PHONY: maskrom run image flash
maskrom:
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
	cat rkbin/rk33/rk3328_usbplug*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L
	sleep 1s
	rkflashtool e 64 32704
	rkflashtool b
	sleep 1s
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
	cat rkbin/rk33/rk3328_miniloader*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L
	sleep 2s

flashrom:
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
	cat rkbin/rk33/rk3328_usbplug*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L
	sleep 1s
	rkflashtool e 64 32704
	rkflashtool w 64 8000 < image/rk3328evb-miniloader.img
	rkflashtool b
	sleep 2s
	rkflashtool w 8192 8192 < image/rk3328evb-uboot.bin
	rkflashtool w 16384 8192 < image/rk3328evb-trust.img
	sleep 1s
	rkflashtool b

maskload:
	make maskrom
	rkflashtool w 8192 8192 < image/rk3328evb-uboot.bin
	rkflashtool w 16384 8192 < image/rk3328evb-trust.img
	rkflashtool b
	sleep 1s
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
	cat rkbin/rk33/rk3328_miniloader*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L

reboot:
	rkflashtool b

.PHONY: kernel-menuconfig
kernel-menuconfig:
	make -C kernel ARCH=arm64 $(KERNEL_DEFCONFIG)
	make -C kernel ARCH=arm64 menuconfig
	make -C kernel ARCH=arm64 savedefconfig
	cp kernel/defconfig kernel/arch/arm64/configs/$(KERNEL_DEFCONFIG)

sync:
	rsync --update --checksum -av image/. router.home:/srv/tftp/
