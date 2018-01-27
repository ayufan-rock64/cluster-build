DISTS=bionic xenial

images/ubuntu-%-core-cloudimg-arm64-root.tar.gz:
	wget -O $@.tmp https://partner-images.canonical.com/core/$(filter $(DISTS), $(subst -, ,$@))/current/$(basename $@)
	mv $@.tmp $@

nfsroot/%-containers-arm64.tar.gz: images/ubuntu-%-core-cloudimg-arm64-root.tar.gz
	docker build -t $$(basename $@ .tar.gz) \
		-f images/Dockerfile.ubuntu \
		--build-arg dist=$(filter $(DISTS), $(subst -, ,$(basename $<))) \
		images/
	-docker rm -f $$(basename $@ .tar.gz)
	docker run --name=$$(basename $@ .tar.gz) $$(basename $@ .tar.gz) rm /.dockerenv
	docker export $$(basename $@ .tar.gz) | gzip -c > $@.tmp
	mv $@.tmp $@
	-docker rm -f $$(basename $@ .tar.gz)

xenial-qemu: tftproot/kernel-arm64 \
	xenial-containers-arm64-initrd.img.gz

	qemu-img create -f qcow2 tmp/qemu.qcow2 8G

	qemu-system-aarch64 -cpu 4 -m 4096 -cpu cortex-a57 -M virt -nographic \
		-kernel tftproot/kernel-arm64 \
		-initrd xenial-containers-arm64-initrd.img.gz \
		-append "printk.devkmsg=on console=ttyAMA0,115200n8 rdinit=/sbin/init" \
		-hda tmp/qemu.qcow2 \
		-net user

xenial-containers: nfsroot/xenial-containers-arm64.tar.gz
