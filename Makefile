arm-trusted-firmware:
	git clone https://github.com/ARM-software/arm-trusted-firmware.git

rkbin:
	git clone https://github.com/rockchip-linux/rkbin

rkflashtool:
	git clone https://github.com/rockchip-linux/rkflashtool

u-boot:
	git clone https://github.com/ayufan-rock64/linux-u-boot u-boot -b mainline-master

rkbin/rk33/bl31.bin: arm-trusted-firmware
	make -C $< CROSS_COMPILE="ccache aarch64-linux-gnu-" PLAT=rk3328 bl31
	cp $</build/rk3328/release/bl31.bin $@

image/rk3328evb-trust.img: # rkbin/rk33/bl31.bin
	rkbin/tools/trust_merger blobs/rk3328trust.ini

u-boot/.config: u-boot/configs/evb-rk3328_defconfig
	make -C u-boot evb-rk3328_defconfig

.PHONY: u-boot/u-boot-dtb.bin
u-boot/u-boot-dtb.bin: u-boot/.config
	make -C u-boot CROSS_COMPILE="ccache aarch64-linux-gnu-" all

image/rk3328evb-uboot.bin: u-boot/u-boot-dtb.bin
	rkbin/tools/loaderimage --pack --uboot $< $@

image: image/rk3328evb-trust.img image/rk3328evb-uboot.bin

run: image
	rkflashtool/rkflashloader rk3328evb

.PHONY: maskrom run image
maskrom:
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
	cat rkbin/rk33/rk3328_usbplug*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L

flash:
	dd if=rkbin/rk33/rk3328_miniloader*.bin of=miniloader.tmp bs=4 skip=1
	u-boot/tools/mkimage -n rk33xx -T rksd -d miniloader.tmp miniloader.img
	rkflashtool w 64 8128 < miniloader.img
	rkflashtool w 0x2000 0x2000 < image/rk3328evb-uboot.bin
	rkflashtool w 0x4000 0x2001 < image/rk3328evb-trust.img
