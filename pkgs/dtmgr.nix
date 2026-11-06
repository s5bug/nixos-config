{
  callPackage,
  fetchFromGitHub,
  nix-update-script,
}: let
  src = fetchFromGitHub {
    owner = "s5bug";
    repo = "dtmgr";
    rev = "26263f7fdd7594539624dc3cbb434269616328b2";
    hash = "sha256-mFuvQNYqY5Fqlp07RqX3QZ/e3Q4JHeaE4S8UImzig/c=";
  };
in
  (callPackage "${src}/package.nix" {}).overrideAttrs {
    version = "0-unstable-2026-11-04";
    inherit src;

    passthru.updateScript = nix-update-script {
      extraArgs = ["--flake" "--version=branch"];
    };
  }
