{
  pkgs,
  javaPackages,
  fetchurl,
  nix-update-script,
}: let
  jdk-26 = javaPackages.compiler.temurin-bin.jdk-26;
in
  (pkgs.sbt.overrideAttrs (finalAttrs: prevAttrs: {
    version = "2.0.5";

    src = fetchurl {
      url = "https://github.com/sbt/sbt/releases/download/v${finalAttrs.version}/sbt-${finalAttrs.version}.tgz";
      hash = "sha256-KlPJVAPLf8zV2gXUjP4D/0vlc6Pz0ClaQZY7EJ51ahg=";
    };

    passthru =
      (prevAttrs.passthru or {})
      // {
        updateScript = nix-update-script {
          extraArgs = [
            "--flake"
          ];
        };
      };
  })).override {
    jre = jdk-26;
  }
