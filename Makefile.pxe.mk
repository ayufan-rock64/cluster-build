tftproot/pxelinux.cfg/%: blobs/pxelinux.cfg/%
	mkdir -p $$(dirname $@)
	cp $< $@

tftproot-pxelinux.cfg: \
	$(patsubst blobs/%, tftproot/%, $(wildcard blobs/pxelinux.cfg/*))
	ln -sf ubuntu-nfs tftproot/pxelinux.cfg/default-arm
