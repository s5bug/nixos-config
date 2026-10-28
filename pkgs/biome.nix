{
  pkgs,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:
pkgs.biome.overrideAttrs (finalAttrs: prevAttrs: {
  version = "2.6.3";

  src = fetchFromGitHub {
    owner = "biomejs";
    repo = "biome";
    rev = "@biomejs/biome@${finalAttrs.version}";
    hash = "sha256-2FceNaMSmfLsG8K1mU/UPGOyG8MhNH5XVjsUcqafaUg=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-tOdx0nAeFGURqqjMYlRwbkdvxw0Yk6Io7mT+9v9G7tE=";
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
