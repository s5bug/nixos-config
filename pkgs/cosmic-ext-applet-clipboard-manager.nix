{
  callPackage,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
  cosmic-ext-applet-clipboard-manager-pkg,
}: let
  cosmic-ext-applet-clipboard = callPackage cosmic-ext-applet-clipboard-manager-pkg {};
in (cosmic-ext-applet-clipboard.overrideAttrs (finalAttrs: prevAttrs: {
  version = "0.1.0-unstable-2026-10-25";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "clipboard-manager";
    rev = "27a246fab0c3051a89f67e137dddada1869145ca";
    hash = "sha256-SsP4DxaJtzfvQkGWQ+fZcIgUngyP94LRh+ymffowNHw=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-ABo4fAtFCaIyNukOUZqHpBhR0fANkb/h7lz755LyRpA=";
  };

  passthru =
    (prevAttrs.passthru or {})
    // {
      updateScript = nix-update-script {
        extraArgs = [
          "--flake"
          "--version=branch"
        ];
      };
    };
}))
