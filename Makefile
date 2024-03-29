ifeq ($(strip $(DEVKITPPC)),)
$(error "Please set DEVKITPPC in your environment. export DEVKITPPC=<path to>devkitPPC)
endif
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM)
endif

DEVKITPRO := $(shell dirname $(DEVKITPPC))

PPC_CC := $(DEVKITPPC)/bin/powerpc-eabi-gcc

PPC_CFLAGS += -g -O2 -Wall -DGEKKO -mrvl -mcpu=750 -meabi -mhard-float -I$(DEVKITPRO)/libogc/include -Icommon
PPC_LDFLAGS += -L$(DEVKITPRO)/libogc/lib/wii -lfat -logc

ARM_AS := $(DEVKITARM)/bin/arm-none-eabi-as
ARM_CC := $(DEVKITARM)/bin/arm-none-eabi-gcc

ARM_ASFLAGS += -mbig-endian -mcpu=arm926ej-s
ARM_CCFLAGS += -Os -Wall -mbig-endian -mcpu=arm926ej-s -mthumb -fomit-frame-pointer -fno-builtin-printf -Icommon
ARM_LDFLAGS += -nostartfiles -nodefaultlibs -n -Wl,-no-warn-rwx-segments

APP_C_FILES := $(wildcard app/*.c)
APP_O_FILES := $(patsubst app/%.c,build/app/%.o,$(APP_C_FILES))

COMMON_C_FILES := $(wildcard common/*.c)
COMMON_O_FILES := $(patsubst common/%.c,build/common/%.o,$(COMMON_C_FILES))

LOADER_S_FILES := $(wildcard loader/*.s)
LOADER_C_FILES := $(wildcard loader/*.c)
LOADER_O_FILES := $(patsubst loader/%.s,build/loader/%.o,$(LOADER_S_FILES)) $(patsubst loader/%.c,build/loader/%.o,$(LOADER_C_FILES))

IOS_S_FILES := $(wildcard ios/*.s)
IOS_C_FILES := $(wildcard ios/*.c)
IOS_O_FILES := $(patsubst ios/%.s,build/ios/%.o,$(IOS_S_FILES)) $(patsubst ios/%.c,build/ios/%.o,$(IOS_C_FILES))

PACKAGE_FILES := \
	boot.dol \
	loader.bin \
	ios.bin \
	icon.png \
	meta.xml

$(shell mkdir -p build/app build/common build/ios build/loader build/gz-booter)

.PHONY: all clean format run

all: build/gz-booter.zip

clean:
	$(RM) -r build/

format:
	clang-format -i common/*.{h,c} app/*.c loader/*.c ios/*.c

run: build/gz-booter.zip
	$(DEVKITPRO)/tools/bin/wiiload $<

build/app/%.o: app/%.c
	$(PPC_CC) $(PPC_CFLAGS) -c $< -o $@

build/app/boot.elf: $(APP_O_FILES)
	$(PPC_CC) $^ $(PPC_CFLAGS) $(PPC_LDFLAGS) -Wl,-Map,build/app/boot.map -o $@

build/common/%.o: common/%.c
	$(ARM_CC) $(ARM_CCFLAGS) -c $< -o $@

build/loader/%.o: loader/%.s
	$(ARM_AS) $(ARM_ASFLAGS) $< -o $@

build/loader/%.o: loader/%.c
	$(ARM_CC) $(ARM_CCFLAGS) -c $< -o $@

build/loader/loader.elf: $(COMMON_O_FILES) $(LOADER_O_FILES)
	$(ARM_CC) $^ $(ARM_CFLAGS) $(ARM_LDFLAGS) -Wl,-T,loader.ld,-Map,build/loader/loader.map -o $@

build/ios/%.o: ios/%.s
	$(ARM_AS) $(ARM_ASFLAGS) $< -o $@

build/ios/%.o: ios/%.c
	$(ARM_CC) $(ARM_CCFLAGS) -c $< -o $@

build/ios/ios.elf: $(COMMON_O_FILES) $(IOS_O_FILES)
	$(ARM_CC) $^ $(ARM_CFLAGS) $(ARM_LDFLAGS) -Wl,-T,ios.ld,-Map,build/ios/ios.map -o $@

build/gz-booter/boot.dol: build/app/boot.elf
	$(DEVKITPRO)/tools/bin/elf2dol $< $@

build/gz-booter/loader.bin: build/loader/loader.elf
	$(DEVKITARM)/bin/arm-none-eabi-objcopy -O binary $< $@

build/gz-booter/ios.bin: build/ios/ios.elf
	$(DEVKITARM)/bin/arm-none-eabi-objcopy -O binary $< $@

build/gz-booter/icon.png: icon.png
	cp $< $@

build/gz-booter/meta.xml: meta.xml
	cp $< $@

build/gz-booter.zip: $(PACKAGE_FILES:%=build/gz-booter/%)
	cd build && zip -r gz-booter.zip gz-booter
