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
      perSystem = {
        pkgs,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;

        packages = let
          packageFiles = builtins.readDir ./pkgs;
          packageNames = map (pkgs.lib.removeSuffix ".nix") (builtins.attrNames packageFiles);

          # every package name ends up being `name = callPackage (...) {}`
          # we can just make the packages a recursive scope because nix will handle the laziness for us
          callPackage = pkgs.newScope resolvedPackages;
          resolvedPackages = pkgs.lib.genAttrs packageNames (name:
            callPackage (./pkgs + "/${name}.nix") {}
          );

          # we need X-pkg to be updated before X
          # so X < Y is lexicographic/alphabetical UNLESS X = Y-pkg, then Y-pkg comes first
          packageNamesByUpdateOrder = builtins.sort (a: b:
            if b == "${a}-pkg" then false # false ⇒ b comes before a
            else if a == "${b}-pkg" then true # true ⇒ a comes before b
            else a < b
          ) packageNames;

          updateScript = pkgs.writeShellScriptBin "update" ''
            if [ -e 'result' ]; then
              echo "\`result\` file already exists and will be clobbered by nix-update bug" >&2
              echo "not performing nix-update in case a previous build's result was important" >&2
            else
              ${pkgs.lib.concatMapStringsSep "\n      " (name:
                ''"${pkgs.nix-update}/bin/nix-update" ${name} --flake --use-update-script''
              ) packageNamesByUpdateOrder}
              rm result
            fi
          '';
        in resolvedPackages // { update = updateScript; };
      };
      flake = {
        nixosConfigurations.hydrogen = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [
            ./configuration.nix
            ({config, ...}: {
              nixpkgs.overlays = [
                (final: prev: {
                  inherit (self.packages.${config.nixpkgs.hostPlatform.system}) cosmic-ext-applet-clipboard-manager sbt;
                })
              ];
            })
          ];
        };
      };
    };
}
