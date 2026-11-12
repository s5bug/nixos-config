{
  pkgs,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:
pkgs.biome.overrideAttrs (finalAttrs: prevAttrs: {
  version = "2.6.7";

  src = fetchFromGitHub {
    owner = "biomejs";
    repo = "biome";
    rev = "@biomejs/biome@${finalAttrs.version}";
    hash = "sha256-1LVKWxLYTBDkVKbMJTOw7sEDSMcWuzkj01kuaatN/Hs=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-WvEUYPiS+J8MIhKGfIkGQgxt8i5XmQHpjzZ93yVGVXA=";
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
