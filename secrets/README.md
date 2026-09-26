# Secrets

agenix encrypts each secret to a **public** age recipient at encrypt time. The
ciphertext is committed; the plaintext never is.

| File              | Committed? | What it is                                     |
| ----------------- | ---------- | ---------------------------------------------- |
| `agent.nix`       | no         | Plaintext. Provider keys and the server password. |
| `agent.age`       | yes        | The same secret, encrypted. This is what the configuration reads. |
| `recipient.txt`   | yes        | The public age key. Safe; it can only encrypt. |
| `identity.age`    | no         | The **private** key. Can decrypt. Back it up.  |

## Changing a secret

```sh
$EDITOR secrets/agent.nix
agenix -e secrets/agent.nix            # rewrites secrets/agent.age
git add secrets/agent.age && git commit -m "rotate agent credentials"
```

`agenix -e` reads the recipient from `secrets/recipient.txt`. If you add a
second recipient, encrypt to both:

```sh
agenix -e secrets/agent.nix -r age1... -r age1...
```

A secret encrypted to a recipient that `tianma1` cannot read will build
perfectly well and then fail to decrypt during activation. There is no
build-time check for this, which is why the recipient is a separate,
human-maintained file rather than something the module validates.

## The identity

`identity.age` is the private key. **Whoever holds it can read every secret in
this repository.** It is gitignored, and the only copy is on this machine.

Before putting a real credential in `agent.nix`, put `identity.age` somewhere
that is not this repository and not this machine — a password manager, an
encrypted note, an offline copy. There is no recovery if it is lost: every
`.age` file in `secrets/` becomes permanently unreadable, and the only fix is
to rotate every credential from scratch.

The current recipient is a placeholder generated while bootstrapping this
repository, and the keys in `agent.nix` are all `REPLACE_ME`. Nothing real has
been encrypted yet, so replacing the identity now costs nothing.

## Why the agent is not enabled yet

`mkononenko.agent.enable` is off in `configurations/tianma1`. Turning it on
before the identity is bound to the host would give a machine that enables
agenix and then cannot decrypt anything it needs.

To enable it:

1. Install the identity on the host as `/run/agenix/identity.age`, readable by
   root only, or bind it to the host's SSH host key:

   ```sh
   agenix -R -i secrets/identity.age age/identity.age
   ```

   The second form is better: it stores the identity encrypted to the host key,
   so the plaintext identity never has to sit on the server.

2. Fill in `secrets/agent.nix`, run `agenix -e`, commit the new `agent.age`.

3. Set `mkononenko.agent.enable = true;` in `configurations/tianma1`.

4. Deploy, then join the tailnet and expose the agent:

   ```sh
   sudo tailscale up
   tailscale serve --bg 4096
   ```

`tailscale serve` is not managed by NixOS on purpose. It is state on the node,
and the tailnet ACLs — not this repository — are what actually decide who may
connect.
