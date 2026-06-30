{
  stdenvNoCC,
  fetchFromGitHub,
  perl,
  nix-update-script
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dotxcompose";
  version = "0-unstable-2026-06-17";

  src = fetchFromGitHub {
    owner = "kragen";
    repo = "xcompose";
    rev = "2131a4712910a0df23be46bdfae5ff812dd295a9";
    hash = "sha256-xFprIrOgvniglZpjCOYPwo693G8fpFQ2eHvPeFeOocM=";
  };

  nativeBuildInputs = [ perl ];

  postPatch = ''
    patchShebangs .
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out

    cp dotXCompose $out/
    cp frakturcompose $out/
    cp *.compose $out/
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "--version=branch"
      ];
    };
  };
})
