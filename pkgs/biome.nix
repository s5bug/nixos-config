{
  pkgs,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:
pkgs.biome.overrideAttrs (finalAttrs: prevAttrs: {
  version = "2.6.4";

  src = fetchFromGitHub {
    owner = "biomejs";
    repo = "biome";
    rev = "@biomejs/biome@${finalAttrs.version}";
    hash = "sha256-/oaXa8UrmKFM431oWMQj1acCgwGwYBn9eTqzlr4xwYs=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-U7sufX7qaMZLkq64ct8rgD8O7p5JokCOhnImhzg77GY=";
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
