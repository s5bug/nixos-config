{
  callPackage,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
  cosmic-ext-applet-clipboard-manager-pkg,
}: let
  cosmic-ext-applet-clipboard = callPackage cosmic-ext-applet-clipboard-manager-pkg {};
in (cosmic-ext-applet-clipboard.overrideAttrs (finalAttrs: prevAttrs: {
  version = "0.1.0-unstable-2026-09-24";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "clipboard-manager";
    rev = "1914df800d0626316161031453047dbc4015e8ad";
    hash = "sha256-164MiyRI2hrkiAl+rhGJMLlqcldXBqnrjPK8jsN9v3g=";
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
