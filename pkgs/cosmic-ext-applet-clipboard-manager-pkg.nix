{
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cosmic-ext-applet-clipboard-manager-pkg";
  version = "0-unstable-2026-11-12";
  # Hack due to nix-update using Regex
  rev = "d56008996ae1f7383cbef498007ff78989122af4";

  src = fetchurl {
    url = "https://github.com/kritdass/nixpkgs/raw/${finalAttrs.rev}/pkgs/by-name/co/cosmic-ext-applet-clipboard-manager/package.nix";
    hash = "sha256-Bgz91AfniwvpB2dhoJjbDnlcyNqa9K6AASsbrFMHsQY=";
  };

  dontUnpack = true;

  installPhase = ''
    cp $src $out
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "--version=branch=cosmic-ext-applet-clipboard-manager"
      ];
    };
  };
})
