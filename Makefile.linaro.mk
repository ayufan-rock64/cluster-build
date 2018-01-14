LINARO_URL ?= https://releases.linaro.org/components/toolchain/binaries/6.4-2017.11/aarch64-linux-gnu/gcc-linaro-6.4.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz
LINARO ?= $(basename $(basename $(notdir $(LINARO_URL))))
LINARO_CC ?= ccache $(CURDIR)/$(LINARO)/bin/aarch64-linux-gnu-

linaro: $(LINARO)

$(LINARO):
	curl -L $(LINARO_URL) | \
		tar Jx
