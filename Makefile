all: image

include Makefile.kernel.mk
include Makefile.linaro.mk
include Makefile.pxe.mk
include Makefile.rancheros.mk
include Makefile.sunxi.mk

image: image-kernel \
	image-pxe \
	image-rancher

sync:
	rsync --delete --update --checksum -av image/. router.home:/srv/tftp/
