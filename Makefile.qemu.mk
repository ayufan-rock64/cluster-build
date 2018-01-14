.PHONY: qemu
qemu: tftproot/kernel-arm64 \
	tftproot/rancheros-initrd-arm64.img.gz

	qemu-img create -f qcow2 tmp/qemu.qcow2 8G

	qemu-system-aarch64 -cpu 4 -m 4096 -cpu cortex-a57 -M virt -nographic \
		-kernel tftproot/kernel-arm64 \
		-initrd tftproot/rancheros-initrd-arm64.img.gz \
		-append "printk.devkmsg=on console=ttyAMA0,115200n8 rancher.autologin=ttyAMA0 rancher.defaults.hostname=ros rancher.state.dev=LABEL=RANCHER_STATE rancher.state.autoformat=[/dev/vda,/dev/sda] rancher.state.wait=true rancher.state.required=true" \
		-hda tmp/qemu.qcow2 \
		-net user
