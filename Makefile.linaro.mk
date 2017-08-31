LINARO ?= gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu
LINARO_URL ?= https://releases.linaro.org/components/toolchain/binaries/latest/aarch64-linux-gnu
LINARO_CC ?= ccache $(CURDIR)/$(LINARO)/bin/aarch64-linux-gnu-

linaro: $(LINARO)

$(LINARO):
	curl -L $(LINARO_URL)/$@.tar.xz | \
		tar Jx
