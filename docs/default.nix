{
  stdenvNoCC,
  lib,
  python3,
  nixdomainObjects,
  doctype
}:
stdenvNoCC.mkDerivation {
  pname = "nix-config-docs";
  version = "0.0.1";
  
  src = ./.;

  nativeBuildInputs = with python3.pkgs; [
    myst-parser
    sphinx
    sphinx-design
    sphinxcontrib-nixdomain
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    make ${doctype}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/nix-config-docs
    cp -r build/html/* $out/nix-config-docs
    runHook postInstall
  '';

  env.NIXDOMAIN_OBJECTS = nixdomainObjects;

  meta = {
    description = "Nix derivation for nix-config sphinx docs";
  };
}

