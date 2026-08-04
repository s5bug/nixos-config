{
  callPackage,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
  cosmic-ext-applet-clipboard-manager-pkg,
}: let
  cosmic-ext-applet-clipboard = callPackage cosmic-ext-applet-clipboard-manager-pkg {};
in (cosmic-ext-applet-clipboard.overrideAttrs (finalAttrs: prevAttrs: {
  version = "0.1.0-unstable-2026-08-03";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "clipboard-manager";
    rev = "25e2dfde02ab82f58fe184bb8f3394465e99dc88";
    hash = "sha256-XyJwW+yXhrTl6dYsIBBLE29J9ecmuhOBGYv6H+GVVtU=";
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
