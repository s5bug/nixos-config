{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "dtmgr-pkg";
  version = "0.3.1-unstable-2026-11-10";

  src = fetchFromGitHub {
    owner = "s5bug";
    repo = "dtmgr";
    rev = "4d0a77f9d86b8ea8439664dd6444aec3817ef0c0";
    hash = "sha256-9iFJyAZyn06dQYLwkUz7O07UREh4IHuPcpSZcNxRQzY=";
  };

  dontBuild = true;

  installPhase = ''
    cp -r . $out
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };
}
