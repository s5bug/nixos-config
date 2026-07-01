{
  callPackage,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
  cosmic-ext-applet-clipboard-manager-pkg,
}: let
  cosmic-ext-applet-clipboard = callPackage cosmic-ext-applet-clipboard-manager-pkg {};
in (cosmic-ext-applet-clipboard.overrideAttrs (finalAttrs: prevAttrs: {
  version = "0.1.0-unstable-2026-03-24";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "clipboard-manager";
    rev = "d473e8f09e8bc2289a76707898063a13714c79dc";
    hash = "sha256-RNRSShrT7wS4GmQNd3tXtT8G/4qLM9zxntXgBQ6C7ps=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = finalAttrs.src;
    hash = "sha256-+yqFV8HdPjkVny+6FKkZFEQAq1rwe7JXmoTJ7zge8bg=";
  };

  passthru =
    (prevAttrs.passthru or {})
    // {
      updateScript = nix-update-script {
        extraArgs = [
          "--flake"
          "--version=branch"
        ];
      };
    };
}))
