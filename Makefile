all: tftproot

include Makefile.kernel.mk
include Makefile.linaro.mk
include Makefile.pxe.mk
include Makefile.rancheros.mk
include Makefile.sunxi.mk
include Makefile.qemu.mk

.PHONY: tftproot
tftproot: tftproot-kernel \
	tftproot-pxelinux.cfg \
	tftproot-rancheros

.PHONY: sync
sync:
	rsync --delete --update --checksum -av tftproot/. router.home:/srv/tftp/
