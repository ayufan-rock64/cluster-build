RANCHER_VERSION ?= v1.1.0

tmp/rancheros-initrd-arm64-$(RANCHER_VERSION).img.gz:
	mkdir -p tmp
	wget -O $@.tmp https://releases.rancher.com/os/$(RANCHER_VERSION)/rootfs_arm64.tar.gz
	mv $@.tmp $@

image/rancheros-initrd-arm64.img.gz: tmp/rancheros-initrd-arm64-$(RANCHER_VERSION).img.gz
	rm -rf tmp/rancheros-initrd
	mkdir tmp/rancheros-initrd
	tar -zxf $< -C tmp/rancheros-initrd
	( cd tmp/rancheros-initrd && find . | fakeroot cpio -o -H newc | gzip -c ) > $@.tmp
	rm -rf tmp/rancheros-initrd
	mv $@.tmp $@

.PHONY: image-rancher
image-rancher: image/rancheros-initrd-arm64.img.gz
