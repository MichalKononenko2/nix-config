{ pkgs, config, lib, ... }: {
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";

  };
}
