{
  callPackage,
  fetchFromGitHub,
  nix-update-script,
}: let
  src = fetchFromGitHub {
    owner = "s5bug";
    repo = "dtmgr";
    rev = "940bf5229d5dc698cd24432aa526ab62512a993b";
    hash = "sha256-vyDclYqd7tcHqWxELyknpiX9zba+k+svAJCt1zxANtQ=";
  };
in
  (callPackage "${src}/package.nix" {}).overrideAttrs {
    version = "0-unstable-2026-10-23";
    inherit src;

    passthru.updateScript = nix-update-script {
      extraArgs = ["--flake" "--version=branch"];
    };
  }
