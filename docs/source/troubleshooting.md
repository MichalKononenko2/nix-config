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

### After the Reboot

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

