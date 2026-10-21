{
  pkgs,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:
pkgs.biome.overrideAttrs (finalAttrs: prevAttrs: {
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "biomejs";
    repo = "biome";
    rev = "@biomejs/biome@${finalAttrs.version}";
    hash = "sha256-L1XyFVPBGnQXmfNBnt2P2CMWlbYJrOeUIpiDspoml78=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-PywPJUVizSd0wNUVr7rxRUa2Hq9MN8Z1PdKLxmuvKTE=";
  };

  # broken test replaces /build/ with <BIOME_DIR> and checks that it's still /build/
  checkFlags =
    (prevAttrs.checkFlags or [])
    ++ [
      "--skip=commands::migrate_stylelint::migrate_stylelintignore_and_ignore_files"
    ];

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
