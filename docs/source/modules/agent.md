# `mkononenko.agent`

```{automodule} mkononenko.agent
```

Declared by
[`modules/agent/default.nix`](https://github.com/MichalKononenko2/nix-config/blob/master/modules/agent/default.nix).

A headless [OpenCode](https://opencode.ai) server, intended for `tianma1`.
Disabled there until an age identity is bound to the host; see
[`secrets/README.md`](https://github.com/MichalKononenko2/nix-config/blob/master/secrets/README.md).

## The four locks

1. **No privilege.** The `agent` account has *no supplementary groups* — no
   `wheel`, no `docker`, no `networkmanager`. There is deliberately no option to
   add groups, because the only thing the account needs to do is run OpenCode.
2. **No public surface.** The server binds `127.0.0.1`. `--hostname` is
   hard-coded and is not an option; binding it to a routable address would put
   an authenticated but internet-reachable agent on the network.
3. **A second lock on the same door.** `OPENCODE_SERVER_PASSWORD` comes from the
   age secret, so something running on the host, or a `tailscale serve` that
   forwards more widely than intended, still has to authenticate.
4. **Nothing to steal.** Credentials are decrypted into `/run/agenix`, never the
   Nix store and never the account's home directory.

## What is deliberately *not* hardened

No `MemoryDenyWriteExecute` and no `SystemCallFilter`. OpenCode is a Bun program
and Bun JIT-compiles at runtime, which requires writable-executable memory.
Either option yields a unit that starts cleanly and then dies on the first
request — a far more expensive failure than a slightly wider syscall surface.

Everything else in `systemd.services.opencode.serviceConfig` is set:
`ProtectSystem = "strict"`, `ProtectHome`, `PrivateTmp`, `PrivateDevices`,
`NoNewPrivileges`, an empty `CapabilityBoundingSet`, the `ProtectKernel*` and
`Restrict*` families, and `RestrictAddressFamilies` limited to `AF_UNIX`,
`AF_INET` and `AF_INET6`.

## From an age secret to a running process

agenix decrypts a Nix attribute set. A process environment is a flat map of
strings. The bridge has to run on the host, because nothing at build time can
read an encrypted value. Three units:

| Unit                  | Role                                                      |
| --------------------- | --------------------------------------------------------- |
| `opencode-secrets`    | `nix eval --file /run/agenix/agent` \| `jq` → a sourceable file |
| `opencode-config`     | installs the generated `opencode.json` into the state directory |
| `opencode`            | sources the environment, then `exec`s the server          |

The environment file is **shell-quoted, not a systemd `EnvironmentFile`.**
systemd's parser expects values quoted in its own dialect, and a generated
password can contain spaces, quotes and backslashes. `jq @sh` quotes for the
shell instead. A useful side effect: a secret containing `$(...)` or backticks
is passed through literally and cannot execute anything in the wrapper.

Because the environment is sourced rather than declared, the credentials do not
appear in `systemctl show` output.

`HOME` is set to the state directory so OpenCode's XDG lookups for `~/.config`
and `~/.local/share` land inside a directory systemd creates and owns, rather
than in a home directory nothing else in this configuration manages. That is
also why the generated `opencode.json` is a Nix value: the account is not a
home-manager user, so a dotfile in its home would be neither reviewable nor
reproducible.

## Rotating a secret

This version of agenix has no `restartUnits`, and the decrypted file lives in
`/run`, so Nix cannot see it change. After re-encrypting:

```sh
sudo systemctl restart opencode.service
```

The two `oneshot` units re-run on every start, so the new credentials are picked
up.

## Reaching it

```sh
tailscale serve --bg 4096
```

This is documented, not applied. A persistent `tailscale serve` is state on the
node rather than a NixOS setting, and the tailnet ACLs — not this repository —
are what actually decide who may connect.
