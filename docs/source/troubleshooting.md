## Troubleshooting

### 2026-04-24: A Broken Touchpad

I checked ``xinput list`` to see if the touchpad responds. The result is

```
⎡ Virtual core pointer                    	id=2	[master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
⎜   ↳ DP-3                                    	id=8	[slave  pointer  (2)]
⎜   ↳ FRMW0001:00 32AC:0006 Consumer Control  	id=10	[slave  pointer  (2)]
⎜   ↳ ImExPS/2 Generic Explorer Mouse         	id=12	[slave  pointer  (2)]
⎜   ↳ MX Anywhere 2 Mouse                     	id=15	[slave  pointer  (2)]
⎣ Virtual core keyboard                   	id=3	[master keyboard (2)]
    ↳ Virtual core XTEST keyboard             	id=5	[slave  keyboard (3)]
    ↳ Video Bus                               	id=6	[slave  keyboard (3)]
    ↳ Power Button                            	id=7	[slave  keyboard (3)]
    ↳ FRMW0001:00 32AC:0006 Wireless Radio Control	id=9	[slave  keyboard (3)]
    ↳ AT Translated Set 2 keyboard            	id=11	[slave  keyboard (3)]
    ↳ DP-3                                    	id=13	[slave  keyboard (3)]
    ↳ FRMW0001:00 32AC:0006 Consumer Control  	id=14	[slave  keyboard (3)]
    ↳ MX Anywhere 2 Keyboard                  	id=16	[slave  keyboard (3)]
```

Nothing there lists a ``Touchpad``. The product is a ```PIXA3854:00 093A:02745 Touchpad```. Attempting
a cold boot to see what happens.

#### After the Reboot

It's back, like it never left.

```
[mkononenko@artax:~]$ xinput list
⎡ Virtual core pointer                    	id=2	[master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
⎜   ↳ DP-3                                    	id=8	[slave  pointer  (2)]
⎜   ↳ FRMW0001:00 32AC:0006 Consumer Control  	id=10	[slave  pointer  (2)]
⎜   ↳ PIXA3854:00 093A:0274 Touchpad          	id=11	[slave  pointer  (2)]
⎜   ↳ PIXA3854:00 093A:0274 Mouse             	id=12	[slave  pointer  (2)]
⎜   ↳ ImExPS/2 Generic Explorer Mouse         	id=14	[slave  pointer  (2)]
⎜   ↳ MX Anywhere 2 Mouse                     	id=17	[slave  pointer  (2)]
⎣ Virtual core keyboard                   	id=3	[master keyboard (2)]
    ↳ Virtual core XTEST keyboard             	id=5	[slave  keyboard (3)]
    ↳ Video Bus                               	id=6	[slave  keyboard (3)]
    ↳ Power Button                            	id=7	[slave  keyboard (3)]
    ↳ FRMW0001:00 32AC:0006 Wireless Radio Control	id=9	[slave  keyboard (3)]
    ↳ AT Translated Set 2 keyboard            	id=13	[slave  keyboard (3)]
    ↳ DP-3                                    	id=15	[slave  keyboard (3)]
    ↳ FRMW0001:00 32AC:0006 Consumer Control  	id=16	[slave  keyboard (3)]
    ↳ MX Anywhere 2 Keyboard                  	id=18	[slave  keyboard (3)]


```


### 2026-05-25: Broken Nix Flake Check

I ran `nix flake update` and then `nix flake check`. 
Nothing was out of the ordinary on my machine.
On merging [PR #24](https://github.com/MichalKononenko2/nix-config/pull/24),
the [continuous integration job](https://github.com/MichalKononenko2/nix-config/pull/24)
failed. The problem is due to a bad [nix-openclaw](openclaw/nix-openclaw-tools) build
getting pushed to mainline. 

The solution is to `nix flake update` only one package. The nix reference
manual [section 8.5.28](https://nix.dev/manual/nix/2.25/command-ref/new-cli/nix3-flake-update)
lists more information.

