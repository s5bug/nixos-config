{
  inputs = {
    adios-flake.url = "github:Mic92/adios-flake";

    # This is pointing to an unstable release.
    # If you prefer a stable release instead, you can change the word unstable to the latest number shown here: https://nixos.org/download
    # i.e. nixos-24.11
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Language Model powered Kana replacements for fcitx5
    nix-hazkey = {
      url = "github:aster-void/nix-hazkey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    adios-flake,
    nixpkgs,
    self,
    ...
  }:
    adios-flake.lib.mkFlake {
      inherit inputs self;
      systems = ["x86_64-linux"];
      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;

        packages.cosmic-ext-applet-clipboard-manager-pkg = pkgs.callPackage ./pkgs/cosmic-ext-applet-clipboard-manager-pkg.nix {};
        packages.cosmic-ext-applet-clipboard-manager = pkgs.callPackage ./pkgs/cosmic-ext-applet-clipboard-manager.nix {};
        packages.sbt = pkgs.callPackage ./pkgs/sbt.nix {};

        packages.update = pkgs.writeShellScriptBin "update" ''
          if [ -e 'result' ]; then
            echo "\`result\` file already exists and will be clobbered by nix-update bug" >&2
            echo "not performing nix-update unless a previous build's result was importent" >&2
          else
            "${pkgs.nix-update}"/bin/nix-update cosmic-ext-applet-clipboard-manager-pkg --flake --use-update-script
            "${pkgs.nix-update}"/bin/nix-update sbt --flake --use-update-script
            rm result
          fi
        '';
      };
      flake = {
        nixosConfigurations.hydrogen = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [./configuration.nix ({config, ...}: {
            nixpkgs.overlays = [
              (final: prev: {
                inherit (self.packages.${config.nixpkgs.hostPlatform.system}) cosmic-ext-applet-clipboard-manager sbt;
              })
            ];
          })];
        };
      };
    };
}
