A Wii homebrew app to load GameCube gz with SD card support.

## Building

Install the devkitPro `wii-dev` and `devkitARM` packages and ensure the
`DEVKITPPC` and `DEVKITARM` environment variables are set. Then, run `make`.

## Debugging

If your Wii is connected to the internet, the app can be built and installed
directly from the Homebrew Channel with

```sh
$ WIILOAD=tcp:192.168.0.2 make run
```

Press the home button while in the Homebrew Channel to see your Wii's IP address.

If a USB Gecko is plugged into Memory Card Slot B, debug logs can be read with e.g.

```sh
$ picocom -b 115200 --imap lfcrlf /dev/tty.usbserial-GECKUSB0
```
