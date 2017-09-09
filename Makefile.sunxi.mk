UBOOT_CONFIG := pine64_plus

arm-trusted-firmware-sunxi:
	git clone https://github.com/apritzel/arm-trusted-firmware.git $@

arm-trusted-firmware-sunxi/build/sun50iw1p1/release/bl31.bin: arm-trusted-firmware-sunxi gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu
	make -C $< CROSS_COMPILE="$(LINARO_CC)" PLAT=sun50iw1p1 bl31

arm-trusted-firmware-sunxi/build/sun50iw1p1/debug/bl31.bin: arm-trusted-firmware-sunxi gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu
	make -C $< CROSS_COMPILE="$(LINARO_CC)" PLAT=sun50iw1p1 DEBUG=1 bl31

u-boot-sunxi:
	git clone https://github.com/linux-sunxi/u-boot-sunxi $@ --single-branch --depth=30

u-boot-sunxi/configs/%_defconfig: u-boot-sunxi

tmp/u-boot-sunxi-%/.config: u-boot-sunxi/configs/%_defconfig
	make -C u-boot-sunxi $(shell basename $<) KBUILD_OUTPUT=$(CURDIR)/$(shell dirname $@)

tmp/u-boot-sunxi-%/spl/sunxi-spl.bin tmp/u-boot-sunxi-%/u-boot.itb: tmp/u-boot-sunxi-%/.config arm-trusted-firmware-sunxi/build/sun50iw1p1/debug/bl31.bin
	make -C u-boot-sunxi ARCH=arm CROSS_COMPILE="$(LINARO_CC)" BL31="$(CURDIR)/$(word 2,$^)" u-boot-sunxi-with-spl.bin spl/sunxi-spl.bin u-boot.itb -j4 KBUILD_OUTPUT=$(CURDIR)/$(shell dirname $<)

tmp/u-boot-sunxi-%/u-boot-with-spl.bin: tmp/u-boot-sunxi-%/spl/sunxi-spl.bin tmp/u-boot-sunxi-%/u-boot.itb
	cat $^ > $@.tmp
	mv $@.tmp $@

image/pine64_plus-uboot.bin: tmp/u-boot-sunxi-pine64_plus/u-boot-with-spl.bin
	cp $^ $@

image/sopine_baseboard-uboot.bin: tmp/u-boot-sunxi-sopine_baseboard/u-boot-with-spl.bin
	cp $^ $@

image-sunxi: \
	image/pine64_plus-uboot.bin \
	image/sopine_baseboard-uboot.bin

