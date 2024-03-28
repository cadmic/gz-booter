A Wii homebrew app to load GameCube gz with SD card support.

## Building

Install the devkitPro `wii-dev` package group and run `make`.

## Debugging

If a USB Gecko is plugged into Memory Card Slot B, debug logs can be read with e.g.

```sh
$ picocom -b 115200 --imap lfcrlf /dev/tty.usbserial-GECKUSB0
```

and the app can be built and launched directly with

```sh
$ WIILOAD=/dev/tty.usbserial-GECKUSB0 make run
```
