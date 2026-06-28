{pkgs, ...}: {
  home.packages = with pkgs; [
    (discord-canary.override {withMoonlight = true;})
    xivlauncher
    prismlauncher
    ghostty
    jetbrains-toolbox
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

  home.stateVersion = "26.05";
}
