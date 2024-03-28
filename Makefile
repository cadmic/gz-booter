ifeq ($(strip $(DEVKITPPC)),)
$(error "Please set DEVKITPPC in your environment. export DEVKITPPC=<path to>devkitPPC)
endif

DEVKITPRO := $(shell dirname $(DEVKITPPC))

PPC_CC := $(DEVKITPPC)/bin/powerpc-eabi-gcc

PPC_CFLAGS += -g -O2 -Wall -DGEKKO -mrvl -mcpu=750 -meabi -mhard-float -I$(DEVKITPRO)/libogc/include
PPC_LDFLAGS += -L$(DEVKITPRO)/libogc/lib/wii -logc

$(shell mkdir -p build/app build/gz-booter)

.PHONY: all clean format run

all: build/gz-booter.zip

clean:
	$(RM) -r build/

format:
	clang-format -i app/*.c

run: build/gz-booter.zip
	$(DEVKITPRO)/tools/bin/wiiload $<

APP_C_FILES := $(wildcard app/*.c)
APP_O_FILES := $(patsubst app/%.c,build/app/%.o,$(APP_C_FILES))

build/app/%.o: app/%.c
	$(PPC_CC) $(PPC_CFLAGS) -c $< -o $@

build/app/boot.elf: $(APP_O_FILES)
	$(PPC_CC) $^ $(PPC_CFLAGS) $(PPC_LDFLAGS) -Wl,-Map,build/app/boot.map  -o $@

PACKAGE_FILES := \
	boot.dol \
	icon.png \
	meta.xml

build/gz-booter/boot.dol: build/app/boot.elf
	$(DEVKITPRO)/tools/bin/elf2dol $< $@

build/gz-booter/icon.png: icon.png
	cp $< $@

build/gz-booter/meta.xml: meta.xml
	cp $< $@

build/gz-booter.zip: $(PACKAGE_FILES:%=build/gz-booter/%)
	cd build && zip -r gz-booter.zip gz-booter
