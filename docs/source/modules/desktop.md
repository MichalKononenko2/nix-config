# `mkononenko.desktop`

```{automodule} mkononenko.desktop
```

Declared by
[`modules/desktop/default.nix`](https://github.com/MichalKononenko2/nix-config/blob/master/modules/desktop/default.nix).
Enabled by
[`configurations/artax`](https://github.com/MichalKononenko2/nix-config/blob/master/configurations/artax).

Switches on the graphical stack: Xorg with a US keyboard layout, XFCE as the
desktop environment with `noDesktop` and its own window manager disabled, and
XMonad as the window manager, configured from `xmonad.hs` in the same
directory.

Also enables PipeWire with ALSA, PulseAudio and JACK, Bluetooth with
Blueman, CUPS, Transmission, and NetworkManager. `services.pulseaudio` is
disabled explicitly because PipeWire provides the PulseAudio server.

The locale and time zone options exist here rather than in the host
configuration because they are inseparable from having a human at the
keyboard.
