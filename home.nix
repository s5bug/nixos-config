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
    # TODO figure out a way to declaratively set idea.filewatcher.executable.path
    fsnotifier

    pnpm
    nodejs_latest
    jdk-26
    sbt
    rustup
    stdenv.cc

    gimp-with-plugins
    inkscape-with-extensions

    (pkgs.writeShellScriptBin "update-rebuild-gui" ''
      CHOICE=$(${pkgs.zenity}/bin/zenity --list --radiolist --title="Update & Shut Down" --text="Action:" --column="Select" --column="Action" --hide-header \
          TRUE "Rebuild and Shut Down" \
          FALSE "Update, Rebuild, and Shut Down" \
          --width=550 --height=200)

      if [ "$?" != "0" ] || [ -z "$CHOICE" ]; then
        exit 0
      fi

      if [ "$CHOICE" = "Rebuild and Shut Down" ]; then
        doas ${pkgs.systemd}/bin/systemctl start rebuild-and-shutdown.service
      else
        doas ${pkgs.systemd}/bin/systemctl start update-rebuild-and-shutdown.service
      fi
    '')

    (pkgs.makeDesktopItem {
      name = "rebuild-and-shutdown-desktop";
      desktopName = "Rebuild & Shut Down";
      icon = "system-shutdown";
      exec = "update-rebuild-gui";
      terminal = false;
      categories = ["System" "Utility"];
    })
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

  services.hazkey = {
    enable = true;
    zenzai.package = inputs.nix-hazkey.packages."x86_64-linux".zenzai_v3_2-small;
  };
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
  };

  # Explicitly specify cursor
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.pop-icon-theme;
    name = "Pop";
    size = 16;
  };

  # include compose files from dotXCompose project
  home.file.".XCompose".text = ''
    include "${pkgs.dotxcompose}/dotXCompose"
    include "${pkgs.dotxcompose}/emoji.compose"
    include "${pkgs.dotxcompose}/modletters.compose"
    include "${pkgs.dotxcompose}/maths.compose"
    include "${pkgs.dotxcompose}/parens.compose"
  '';

  home.sessionVariables = {
    # shortcut for where the nix config is
    NC = "/home/aly/Documents/nixos-config";

    # fix for `pnpm biome`
    BIOME_BINARY = "${pkgs.biome}/bin/biome";

    # fix for `pnpm astro dev`
    MINIFLARE_WORKERD_PATH = "${pkgs.wrangler}/bin/workerd";
  };

  home.stateVersion = "26.05";
}
