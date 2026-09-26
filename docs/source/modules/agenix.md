# `mkononenko.agenix`

```{automodule} mkononenko.agenix
```

Declared by
[`modules/agenix/default.nix`](https://github.com/MichalKononenko2/nix-config/blob/master/modules/agenix/default.nix).

A thin, documented wrapper around agenix's own `age.*` options. It exists for
two reasons, both of which came from getting this wrong first.

## Why recipients are not an option here

agenix has **no option for recipients**. A recipient is only used by `agenix -e`
at encrypt time; at runtime agenix only needs something it can decrypt *with*.
Declaring a `recipients` option in the NixOS configuration would look
authoritative while doing nothing, and would rot silently the first time
somebody rotated a key and forgot to update it.

The recipient therefore lives with the tooling that consumes it, in
[`secrets/`](https://github.com/MichalKononenko2/nix-config/blob/master/secrets),
next to the `agenix -e` commands. See
[`secrets/README.md`](https://github.com/MichalKononenko2/nix-config/blob/master/secrets/README.md).

The uncomfortable consequence: **nothing checks that a secret is encrypted to
a recipient the host can read.** A mismatch builds perfectly and then fails to
decrypt during activation.

## identityPaths is not optional

`age.identityPaths` defaults to the host's SSH host key,
`/etc/ssh/ssh_host_ed25519_key`. That is the standard flow: the identity at
`age/identity.age` is itself encrypted to the host key, so activation recovers
it without a plaintext identity ever being on the machine.

agenix **refuses to activate when the list is empty**, so there is no "unset"
state to fall back on. The module asserts that OpenSSH is enabled whenever
`identityPaths` is non-empty, since the default path does not exist otherwise.

## Secrets are declared by their consumer

`age.secrets` is a free-form attrset, and its fields are type-checked, so a typo
in a field name is an error rather than a silently missing secret. Each module
that needs a secret declares its own entry next to the thing that uses it, which
keeps a secret's owner, mode and lifetime in the same file as its consumer. See
{doc}`agent` for the worked example.
