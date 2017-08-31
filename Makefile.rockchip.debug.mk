run: image
	rkflashtool/rkflashloader rk3328evb

.PHONY: maskrom run image flash
maskrom:
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
	cat rkbin/rk33/rk3328_usbplug*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L
	sleep 1s
	rkflashtool e 64 32704
	rkflashtool b
	sleep 1s
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
	cat rkbin/rk33/rk3328_miniloader*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L
	sleep 2s

flashrom:
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
	cat rkbin/rk33/rk3328_usbplug*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L
	sleep 1s
	rkflashtool e 64 32704
	rkflashtool w 64 8000 < image/rk3328evb-miniloader.img
	rkflashtool b
	sleep 2s
	rkflashtool w 8192 8192 < image/rk3328evb-uboot.bin
	rkflashtool w 16384 8192 < image/rk3328evb-trust.img
	sleep 1s
	rkflashtool b

maskload:
	make maskrom
	rkflashtool w 8192 8192 < image/rk3328evb-uboot.bin
	rkflashtool w 16384 8192 < image/rk3328evb-trust.img
	rkflashtool b
	sleep 1s
	cat rkbin/rk33/rk3328_ddr_333MHz*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool l
	cat rkbin/rk33/rk3328_miniloader*.bin | openssl rc4 -K 7c4e0304550509072d2c7b38170d1711 | rkflashtool L

reboot:
	rkflashtool b
