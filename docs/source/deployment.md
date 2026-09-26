# Deployment with GitHub actions

Two workflows, split by what they are allowed to do.

## `test.yml` — on every pull request

Runs `nix flake check` with a read-only Cachix token
(`skipPush: true`, since a forked pull request has no write token and should
not be writing to the cache anyway).

`nix flake check` is the whole test suite. It evaluates every
`nixosConfigurations` entry and every `nixosModules` entry, builds the
`checks` derivations, and that includes:

| Check           | What it catches                                                   |
| --------------- | ----------------------------------------------------------------- |
| `docs`          | A Sphinx build that fails, or a module that no longer evaluates  |
| `docs-coverage` | A module under `modules/` with no page under `docs/source/modules/` |
| `home-manager`  | A broken file under `home/`, which `nix flake check` otherwise skips |

``skipPush`` is enabled in ``test.yml``. This is because this workflow should not be pushing
to the cachix cache from a pull request. Pushes to ``cachix`` are only done when the master
branch is built.

## `build_docs.yml` — on every push to `master`

Builds `.#docs` and deploys it to GitHub Pages. This is the only workflow with
a Cachix write token, so merged work populates the cache for everyone else.

Before the first deployment, create a **github-pages** environment in the
repository settings and set its branch protections. The deploy job names it
explicitly, and GitHub will refuse to deploy without the environment's
approval rules satisfied.
