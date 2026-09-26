# `mkononenko.server`

```{automodule} mkononenko.server
```

Declared by
[`modules/server/default.nix`](https://github.com/MichalKononenko2/nix-config/blob/master/modules/server/default.nix).
Enabled by
[`configurations/tianma1`](https://github.com/MichalKononenko2/nix-config/blob/master/configurations/tianma1).

The baseline for a headless machine: SSH, compressed swap in RAM, and a clean
`/tmp` on boot.

## On the SSH defaults

`permitRootLogin` defaults to `prohibit-password` and `passwordAuthentication`
to `false`. Together these refuse every password-based root login while
leaving public-key root login untouched, so switching this module on cannot
lock out an owner who already has a key installed.

That reasoning depends on `mkononenko.server.ssh.authorizedKeys` being
non-empty. It defaults to the empty list and there is deliberately no fallback
key baked into the module — the key belongs in the host configuration, where
who owns the machine is a fact rather than a reusable default.

If you ever set `authorizedKeys = [ ];` on a remote machine, SSH will refuse
every connection and you will need out-of-band recovery. Set it in the same
commit that enables the module, never after.
