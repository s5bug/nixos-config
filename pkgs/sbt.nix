{
  pkgs,
  javaPackages,
  fetchurl,
  nix-update-script,
}: let
  jdk-26 = javaPackages.compiler.temurin-bin.jdk-26;
in
  (pkgs.sbt.overrideAttrs (finalAttrs: prevAttrs: {
    version = "2.0.2";

    src = fetchurl {
      url = "https://github.com/sbt/sbt/releases/download/v${finalAttrs.version}/sbt-${finalAttrs.version}.tgz";
      hash = "sha256-2Ac//RIs6pUONEQPs/4UEgxHGgvyhDxy0n8lg17nJPk=";
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
