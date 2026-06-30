{
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cosmic-ext-applet-clipboard-manager-pkg";
  version = "0-unstable-2026-03-04";
  # Hack due to nix-update using Regex
  rev = "71f8f21a50192425577f92f97eb5212a85dd0588";

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
