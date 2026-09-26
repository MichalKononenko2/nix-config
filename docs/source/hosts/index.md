# Hosts

Each host is a *composition*: it names the hardware it runs on and switches on
the modules it wants. Hosts declare no options of their own, so there is
nothing for {ref}`nix-optionsindex` to render here — the options a host sets are
documented on the module pages under {doc}`../modules/index`.

## `artax`

A laptop. The only desktop machine, and the only one with a home-manager
configuration.

Composition: [`configurations/artax`](https://github.com/MichalKononenko2/nix-config/blob/master/configurations/artax)
imports [`hosts/artax.nix`](https://github.com/MichalKononenko2/nix-config/blob/master/hosts/artax.nix)
— a `nixos-generate-config` hardware scan, not to be edited by hand — plus
every module in [`modules/`](https://github.com/MichalKononenko2/nix-config/blob/master/modules).

Switches on {doc}`../modules/desktop` and
{doc}`../modules/users/mkononenko`, sets `allowUnfree`, and installs a short
list of system-wide tools.

Its home-manager configuration is `mkononenko@artax`, which covers git, the
shell, and direnv.

`system.stateVersion` is `25.05`.

## `tianma1`

A headless Hetzner VPS.

Composition: [`configurations/tianma1`](https://github.com/MichalKononenko2/nix-config/blob/master/configurations/tianma1)
imports [`hosts/tianma1/`](https://github.com/MichalKononenko2/nix-config/blob/master/hosts/tianma1)
— bootloader, initrd modules, and a [disko](https://github.com/nix-community/disko)
disk description — plus the baseline and server modules.

Its network configuration in
[`networking.nix`](https://github.com/MichalKononenko2/nix-config/blob/master/configurations/tianma1/networking.nix)
was captured at install time with `nixos-infect` and contains this host's
specific address and interface MAC. It is not portable.

Two things in this configuration are machine-specific rather than reusable and
are kept here on purpose: the root SSH key, and the `nixos-infect` network
capture.

[agenix](../modules/agenix.md) and
[agent](../modules/agent.md) are available but **not** enabled. agenix refuses
to activate without an identity it can decrypt with, and the identity has not
been bound to this host yet; enabling it now would produce a machine that cannot
decrypt what it needs. The procedure is in
[`secrets/README.md`](https://github.com/MichalKononenko2/nix-config/blob/master/secrets/README.md).

`system.stateVersion` is `25.11`.

## `wsl`

Not a machine. An entry point for building a NixOS image that boots inside
Windows Subsystem for Linux, via
[`nixos-wsl`](https://github.com/nix-community/nixos-wsl).

It enables `wsl` and turns off `resolvconf`, which conflicts with WSL's own
resolver.

`system.stateVersion` is `26.05`.
