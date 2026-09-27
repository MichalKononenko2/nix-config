# Every reusable, option-owning module in this repository.
#
# Importing this directory is how a host opts in to the baseline. Individual
# modules are also exposed individually as `nixosModules.<name>` in the flake,
# which is what the documentation build evaluates.
{
  imports = [
    ./agenix
    ./agent
    ./baseline.nix
    ./desktop
    ./server
    ./users/mkononenko.nix
    ./docs
  ];
}
