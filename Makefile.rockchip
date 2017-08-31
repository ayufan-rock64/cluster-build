arm-trusted-firmware:
	git clone https://github.com/ARM-software/arm-trusted-firmware.git

rkbin:
	git clone https://github.com/rockchip-linux/rkbin

u-boot-rockchip:
	git clone https://github.com/ayufan-rock64/linux-u-boot u-boot-rockchip -b mainline-master

rkbin/rk33/bl31.bin: arm-trusted-firmware gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu
	make -C $< CROSS_COMPILE="$(LINARO_CC)" PLAT=rk3328 bl31
	cp $</build/rk3328/release/bl31.bin $@

u-boot-rockchip/.config: u-boot-rockchip/configs/rock64-rk3328_defconfig
	make -C u-boot-rockchip rock64-rk3328_defconfig

ifeq ($(FORCE), 1)
.PHONY: u-boot-rockchip/u-boot-rockchip-dtb.bin
endif
u-boot-rockchip/u-boot-dtb.bin: u-boot-rockchip/.config
	make -C u-boot-rockchip CROSS_COMPILE="ccache aarch64-linux-gnu-" DEBUG=$(DEBUG) all -j4

.PHONY: u-boot-rockchip-build
u-boot-rockchip-build: image/rk3328evb-uboot.bin

image/rk3328evb-trust.img: # rkbin/rk33/bl31.bin
	rkbin/tools/trust_merger blobs/rk3328trust.ini

image/rk3328evb-miniloader.img:
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | dd of=miniloader.tmp bs=4 skip=1
	u-boot-rockchip/tools/mkimage -n rk3328 -T rksd -d miniloader.tmp $@.tmp
	cat rkbin/rk33/rk3328_miniloader*.bin >> $@.tmp
	mv $@.tmp $@
	rm miniloader.tmp

image/rk3328evb-uboot.bin: u-boot-rockchip/u-boot-dtb.bin
	rkbin/tools/loaderimage --pack --uboot $< $@

.PHONY: image-rockchip
image-rockchip: \
	image/rk3328evb-trust.img \
	image/rk3328evb-miniloader.img \
	image/rk3328evb-uboot.bin
