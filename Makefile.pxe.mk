tftproot/pxelinux.cfg/%: blobs/pxelinux.cfg/%
	mkdir -p $$(dirname $@)
	cp $< $@

tftproot/extlinux/extlinux.conf: blobs/pxelinux.cfg/default-arm-rockchip
	mkdir -p tftproot/extlinux
	cp $< $@

tftproot-pxelinux.cfg: \
	$(patsubst blobs/%, tftproot/%, $(wildcard blobs/pxelinux.cfg/*))
