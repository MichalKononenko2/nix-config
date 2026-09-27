{
  config,
  lib,
  ...
}:

let
  cfg = config.mkononenko.server;
in
{
  options.mkononenko.docs = {
    enable = lib.mkEnableOption "the documentation package";

    buildHtml = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to build the HTML documentation.
      '';
    };

    buildLatex = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to build the LaTeX documentation.
      '';
    };
  };
}

