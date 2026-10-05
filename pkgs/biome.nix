{
  pkgs,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:
pkgs.biome.overrideAttrs (finalAttrs: prevAttrs: {
  version = "2.5.15";

  src = fetchFromGitHub {
    owner = "biomejs";
    repo = "biome";
    rev = "@biomejs/biome@${finalAttrs.version}";
    hash = "sha256-27I1d9cqC0oTMvfef4oYJViIx3QF+3b4WnZIx2gj5c4=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-lC4IGhA6TXlmW0rbMvtnFE6R8SH8sI5uHWsS3t48ruQ=";
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
