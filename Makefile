all: image

include Makefile.kernel.mk
include Makefile.linaro.mk
include Makefile.pxe.mk
include Makefile.rancheros.mk
include Makefile.rockchip.mk
include Makefile.rockchip.debug.mk
include Makefile.sunxi.mk

image: image-kernel \
	image-rockchip \
	image-sunxi \
	image-pxe

sync:
	rsync --delete --update --checksum -av image/. router.home:/srv/tftp/
