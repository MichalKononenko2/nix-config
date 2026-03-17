{
  stdenvNoCC,
  lib,
  python3,
  nixdomainObjects
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
    make html
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/doc/nix-config-docs
    cp -r _build/html $/out/share/doc/nix-config-docs
    runHook postInstall
  '';

  env.NIXDOMAIN_OBJECTS = nixdomainObjects;
}

