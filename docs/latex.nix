{
  stdenvNoCC,
  lib,
  python3,
  texlive,
  nixdomainObjects,
}:
stdenvNoCC.mkDerivation {
  pname = "nix-config-docs-latex";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs =
    (with python3.pkgs; [
      myst-parser
      sphinx
      sphinx-design
      sphinxcontrib-nixdomain
    ])
    ++ [
      # scheme-medium already carries xetex and latexmk; collection-latexextra
      # adds the packages Sphinx's LaTeX style files require (fncychap,
      # tabulary, framed, needspace, upquote, varwidth, wrapfig, ...); and
      # gnu-freefont provides the FreeSerif/FreeSans/FreeMono fonts Sphinx's
      # xelatex template picks as its defaults.
      (texlive.withPackages (
        ps: with ps; [
          scheme-medium
          collection-latexextra
          gnu-freefont
        ]
      ))
    ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    make latexpdf
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/pdf
    cp build/latex/*.pdf $out/pdf/
    runHook postInstall
  '';

  env.NIXDOMAIN_OBJECTS = nixdomainObjects;

  meta = {
    description = "Nix derivation for nix-config LaTeX docs";
  };
}
