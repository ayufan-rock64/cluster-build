image/pxelinux.cfg/%: blobs/pxelinux.cfg/%
	mkdir -p image/pxelinux.cfg
	cp $< $@

image/extlinux/extlinux.conf: blobs/pxelinux.cfg/default-arm-rockchip
	mkdir -p image/extlinux
	cp $< $@

image-pxe: \
	$(patsubst blobs/%, image/%, $(wildcard blobs/pxelinux.cfg/*))
