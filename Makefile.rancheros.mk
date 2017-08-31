tmp/rancheros-initrd-arm64.img.gz:
	mkdir -p tmp
	wget -O $@.tmp https://releases.rancher.com/os/latest/rootfs_arm64.tar.gz
	mv $@.tmp $@

image/rancheros-initrd-arm64.img.gz: tmp/rancheros-initrd-arm64.img.gz
	sudo rm -rf tmp/rancheros-initrd
	sudo mkdir tmp/rancheros-initrd
	sudo tar -zxf $< -C tmp/rancheros-initrd
	( cd tmp/rancheros-initrd && sudo find . | sudo cpio -o -H newc | gzip -c ) > $@.tmp
	sudo rm -rf tmp/rancheros-initrd
	mv $@.tmp $@
