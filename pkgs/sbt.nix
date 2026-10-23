{
  pkgs,
  javaPackages,
  fetchurl,
  nix-update-script,
}: let
  jdk-27 = javaPackages.compiler.temurin-bin.jdk-27;
in
  (pkgs.sbt.overrideAttrs (finalAttrs: prevAttrs: {
    version = "2.0.11";

    src = fetchurl {
      url = "https://github.com/sbt/sbt/releases/download/v${finalAttrs.version}/sbt-${finalAttrs.version}.tgz";
      hash = "sha256-2ECaJE6Xw4OfJ8T0NfSUIRlsEmpFDTD0z1NSLTnjw3k=";
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
    jre = jdk-27;
  }
