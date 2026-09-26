# agenix wiring.
#
# agenix's recipients are *not* configured here, because agenix has no option
# for them. A recipient is only used by `agenix -e` at encrypt time; at runtime
# agenix only ever needs something it can decrypt *with*. Declaring a
# `recipients` option in the NixOS configuration would therefore look
# authoritative while doing nothing at all, and would rot silently the first
# time somebody rotated a key and forgot to update it.
#
# The recipient lives with the encrypt tooling instead, in `secrets/`, next to
# the commands that consume it. See secrets/README.md.
#
# Secrets themselves are also not declared here. agenix's `age.secrets` is a
# free-form attrset whose fields are checked, so a typo is an error rather than
# a silently missing secret. Each module that consumes a secret declares its
# own entry next to the thing that needs it, keeping lifetime, ownership and
# restart behaviour in the same file as the consumer.
{
  config,
  lib,
  ...
}:

let
  cfg = config.mkononenko.agenix;
in
{
  options.mkononenko.agenix = {
    enable = lib.mkEnableOption "agenix secret management";

    secretsDir = lib.mkOption {
      type = lib.types.str;
      default = "/run/agenix";
      example = "/run/agenix";
      description = ''
        Directory agenix materialises decrypted secrets into.

        Defaults to agenix's own location. Exposed so that other modules can
        refer to a secret's path symbolically instead of hard-coding the
        string.
      '';
    };

    identityPaths = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ "/etc/ssh/ssh_host_ed25519_key" ];
      example = [ "/etc/ssh/ssh_host_ed25519_key" ];
      description = ''
        Paths holding age identities usable for decrypting this host's
        secrets.

        Defaults to the host's SSH host key, which is the standard agenix flow:
        the identity at `age/identity.age` is itself encrypted to the host key
        (`agenix -R`), so activation can recover it without a plaintext
        identity ever sitting on the machine.

        agenix refuses to activate with an empty list, so there is no
        "unset" state here. Set it to `[ ]` only together with an explicit
        identity of your own elsewhere.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    age = {
      secretsDir = cfg.secretsDir;
      identityPaths = cfg.identityPaths;
    };

    assertions = [
      {
        assertion = config.age.secrets != { };
        message = ''
          mkononenko.agenix is enabled but no age.secrets are declared.
          Either declare the secrets the host needs, or do not enable this
          module.
        '';
      }
      {
        assertion = cfg.identityPaths == [ ] || config.services.openssh.enable;
        message = ''
          mkononenko.agenix.identityPaths defaults to the host's SSH host key,
          which requires services.openssh.enable. Either enable OpenSSH, or
          point identityPaths at an identity you manage yourself.
        '';
      }
    ];
  };
}
