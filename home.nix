{
  inputs,
  pkgs,
  ...
}: let
  jdk-26 = pkgs.javaPackages.compiler.temurin-bin.jdk-26;

  sbt-new =
    (pkgs.sbt.overrideAttrs (finalAttrs: prevAttrs: {
      version = "2.0.0";

      src = pkgs.fetchurl {
        url = "https://github.com/sbt/sbt/releases/download/v${finalAttrs.version}/sbt-${finalAttrs.version}.tgz";
        hash = "sha256-YwiL1jCcXABphtkWSTV+52lMTkpC3JtvUZifLyHgq5I=";
      };
    })).override {
      jre = jdk-26;
    };

  sbt-new-safe =
    if (builtins.compareVersions pkgs.sbt.version sbt-new.version >= 0)
    then throw "nixpkgs version of SBT (${pkgs.sbt.version}) has caught up to requested (${sbt-new.version})"
    else sbt-new;
in {
  imports = [inputs.nix-hazkey.homeModules.hazkey];

  home.packages = with pkgs; [
    (discord-canary.override {withMoonlight = true;})
    xivlauncher
    prismlauncher
    ghostty
    jetbrains-toolbox

    pnpm
    nodejs_latest
    jdk-26
    sbt-new-safe
    rustup
  ];

  programs.fish.enable = true;

  # Dark mode for legacy applications
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig."gtk-application-prefer-dark-theme" = 1;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Aly";
        email = "me@s5.pm";
      };
      init.defaultBranch = "main";
    };
  };

  programs.zed-editor = {
    enable = true;
    extensions = ["nix"];
    userSettings = {
      languages = {
        Nix = {
          language_servers = ["nixd"];
        };
      };
      lsp = {
        nixd = {
          formatting = {
            command = ["alejandra"];
          };
        };
      };
    };
    extraPackages = with pkgs; [
      nixd
      alejandra
    ];
  };

  services.hazkey.enable = true;
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
  };

  home.stateVersion = "26.05";
}
