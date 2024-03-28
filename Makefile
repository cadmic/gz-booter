ifeq ($(strip $(DEVKITPPC)),)
$(error "Please set DEVKITPPC in your environment. export DEVKITPPC=<path to>devkitPPC)
endif

DEVKITPRO := $(shell dirname $(DEVKITPPC))
TARGET := gz-booter

CC := $(DEVKITPPC)/bin/powerpc-eabi-gcc

CFLAGS += -g -O2 -Wall -DGEKKO -mrvl -mcpu=750 -meabi -mhard-float -I$(DEVKITPRO)/libogc/include
LDFLAGS += -Wl,-Map,build/$(TARGET).map -L$(DEVKITPRO)/libogc/lib/wii -logc

C_FILES := $(wildcard src/*.c)
O_FILES := $(patsubst src/%.c,build/%.o,$(C_FILES))

$(shell mkdir -p build)

.PHONY: all clean format run

all: build/$(TARGET).dol

clean:
	$(RM) -r build/

format:
	clang-format -i src/*.c

run: build/$(TARGET).dol
	$(DEVKITPRO)/tools/bin/wiiload build/$(TARGET).dol

build/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

build/$(TARGET).elf: $(O_FILES)
	$(CC) $^ $(CFLAGS) $(LDFLAGS) -o $@

build/$(TARGET).dol: build/$(TARGET).elf
	$(DEVKITPRO)/tools/bin/elf2dol $< $@
