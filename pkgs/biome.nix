{
  pkgs,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:
pkgs.biome.overrideAttrs (finalAttrs: prevAttrs: {
  version = "2.5.4";

  src = fetchFromGitHub {
    owner = "biomejs";
    repo = "biome";
    rev = "@biomejs/biome@${finalAttrs.version}";
    hash = "sha256-x8oMtugVmN8Z7obBsiZxLZ5Ikj/oGPXEgg/8M8dsRvc=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-yV+lvPLPGtWCtbA39NVH1T1Sl1qn1MTsQIVRo3c9+Dg=";
  };

  passthru =
    (prevAttrs.passthru or {})
    // {
      updateScript = nix-update-script {
        extraArgs = [
          "--flake"
          "--version-regex"
          "@biomejs/biome@(.*)"
        ];
      };
    };
})
