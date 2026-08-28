{
  pkgs,
  javaPackages,
  fetchurl,
  nix-update-script,
}: let
  jdk-26 = javaPackages.compiler.temurin-bin.jdk-26;
in
  (pkgs.sbt.overrideAttrs (finalAttrs: prevAttrs: {
    version = "2.0.8";

    src = fetchurl {
      url = "https://github.com/sbt/sbt/releases/download/v${finalAttrs.version}/sbt-${finalAttrs.version}.tgz";
      hash = "sha256-QMKjF4bTaihvDZ6L/fURgeVAjE+Z6rhVVuK81eEuq0Q=";
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
