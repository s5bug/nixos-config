{
  callPackage,
  fetchFromGitHub,
  nix-update-script,
}: let
  src = fetchFromGitHub {
    owner = "s5bug";
    repo = "dtmgr";
    rev = "7e7591ee1a76d1f9c3fcf06584bd0595737c7b63";
    hash = "sha256-ToxGU+ei6OgiS/UmwTMxp1P8R0h5GqpmcuX+IJzTE88=";
  };
in
  (callPackage "${src}/package.nix" {}).overrideAttrs {
    version = "0-unstable-2026-10-23";
    inherit src;

    passthru.updateScript = nix-update-script {
      extraArgs = ["--flake" "--version=branch"];
    };
  }
