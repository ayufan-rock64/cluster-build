all: image

include Makefile.kernel
include Makefile.linaro
include Makefile.pxe
include Makefile.rancheros
include Makefile.rockchip
include Makefile.rockchip.debug
include Makefile.sunxi

image: image-kernel \
	image-rockchip \
	image-sunxi \
	image-pxe

sync:
	rsync --update --checksum -av image/. router.home:/srv/tftp/
