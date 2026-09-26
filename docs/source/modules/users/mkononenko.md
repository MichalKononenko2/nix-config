# `mkononenko.user.mkononenko`

```{automodule} mkononenko.user.mkononenko
```

Declared by
[`modules/users/mkononenko.nix`](https://github.com/MichalKononenko2/nix-config/blob/master/modules/users/mkononenko.nix).
Enabled by
[`configurations/artax`](https://github.com/MichalKononenko2/nix-config/blob/master/configurations/artax).

The NixOS side of the account: it exists, what it may do, and which system
packages land in its home directory. It is deliberately *not* the whole of
"mkononenko's configuration" — dotfiles, shell configuration, the editor and
git identity live in [`home/mkononenko/`](https://github.com/MichalKononenko2/nix-config/blob/master/home/mkononenko)
under home-manager.

## Why one module per user

A user has two halves that run under different privilege models, and the
directory boundary keeps them honest:

| Concern                        | Lives in                        | Needs root |
| ------------------------------ | ------------------------------- | ---------- |
| Account, groups, system packages | `modules/users/<name>.nix`     | yes        |
| Dotfiles, shell, editor, git    | `home/<name>/`                  | no         |

Because they are separate directories, `nix flake check` can evaluate the
home-manager half on its own, and a broken dotfile cannot take the system
configuration down with it.
