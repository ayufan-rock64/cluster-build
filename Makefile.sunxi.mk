UBOOT_CONFIG := pine64_plus

arm-trusted-firmware-sunxi:
	git clone https://github.com/apritzel/arm-trusted-firmware.git $@

arm-trusted-firmware-sunxi/build/sun50iw1p1/release/bl31.bin: arm-trusted-firmware-sunxi gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu
	make -C $< CROSS_COMPILE="$(LINARO_CC)" PLAT=sun50iw1p1 bl31

arm-trusted-firmware-sunxi/build/sun50iw1p1/debug/bl31.bin: arm-trusted-firmware-sunxi gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu
	make -C $< CROSS_COMPILE="$(LINARO_CC)" PLAT=sun50iw1p1 DEBUG=1 bl31

u-boot-sunxi:
	git clone https://github.com/linux-sunxi/u-boot-sunxi $@ --single-branch --depth=30

u-boot-sunxi/configs/$(UBOOT_CONFIG)_defconfig: u-boot-sunxi

u-boot-sunxi/.config: u-boot-sunxi/configs/$(UBOOT_CONFIG)_defconfig
	make -C u-boot-sunxi $(UBOOT_CONFIG)_defconfig

u-boot-sunxi/spl/sunxi-spl.bin u-boot-sunxi/u-boot.itb: u-boot-sunxi/.config arm-trusted-firmware-sunxi/build/sun50iw1p1/debug/bl31.bin
	make -C u-boot-sunxi ARCH=arm CROSS_COMPILE="$(LINARO_CC)" BL31="$(CURDIR)/$(word 2,$^)" u-boot-sunxi-with-spl.bin spl/sunxi-spl.bin u-boot.itb -j4

image/$(UBOOT_CONFIG)-uboot.bin: u-boot-sunxi/spl/sunxi-spl.bin u-boot-sunxi/u-boot.itb
	cat $^ > $@.tmp
	mv $@.tmp $@

image-sunxi: image/$(UBOOT_CONFIG)-uboot.bin
