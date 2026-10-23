{
  callPackage,
  fetchFromGitHub,
  nix-update-script,
}: let
  src = fetchFromGitHub {
    owner = "s5bug";
    repo = "dtmgr";
    rev = "275c6acab3a5232fb982138133e7c4f9be431ad9";
    hash = "sha256-LX6126nT466sweRfqhEPNOAxkArKKw6pwkTLSqWzjho=";
  };
in
  (callPackage "${src}/package.nix" {}).overrideAttrs {
    passthru.updateScript = nix-update-script {
      extraArgs = ["--flake" "--version=branch"];
    };
  }
