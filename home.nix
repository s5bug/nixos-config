{
  inputs,
  pkgs,
  ...
}: let
  jdk-26 = pkgs.javaPackages.compiler.temurin-bin.jdk-26;
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
    sbt
    rustup
    stdenv.cc
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

  # Explicitly specify cursor
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.pop-icon-theme;
    name = "Pop";
    size = 16;
  };

  home.stateVersion = "26.05";
}
