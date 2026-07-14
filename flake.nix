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
      inputs.home-manager.follows = "home-manager";
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
          resolvedPackages = pkgs.lib.genAttrs packageNames (
            name:
              callPackage (./pkgs + "/${name}.nix") {}
          );

          partitionByPackageType = builtins.partition (name: pkgs.lib.hasSuffix "-pkg" name) packageNames;
          normalPackages = partitionByPackageType.wrong;
          pkgPackages = partitionByPackageType.right;

          # we need to
          # 1. update the pkgPackages
          # 2. build the pkgPackages
          # 3. update the normalPackages
          updateScript = pkgs.writeShellScriptBin "update" ''
            if [ -e 'result' ]; then
              echo "\`result\` file already exists and will be clobbered by nix-update bug" >&2
              echo "not performing nix-update in case a previous build's result was important" >&2
            else
              ${pkgs.lib.concatMapStringsSep "\n    " (
                name: ''"${pkgs.nix-update}/bin/nix-update" ${name} --flake --use-update-script''
              )
              pkgPackages}

              ${pkgs.lib.optionalString (builtins.length pkgPackages > 0) ''
              nix build --no-link ${pkgs.lib.concatMapStringsSep " " (name: ".#${name}") pkgPackages}
            ''}

              ${pkgs.lib.concatMapStringsSep "\n    " (
                name: ''"${pkgs.nix-update}/bin/nix-update" ${name} --flake --use-update-script''
              )
              normalPackages}
              rm -f result
            fi
          '';
        in
          resolvedPackages // {update = updateScript;};
      };
      flake = {
        nixosConfigurations.hydrogen = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [
            ./configuration.nix
            ({config, ...}: {
              nixpkgs.overlays = [
                (
                  final: prev:
                    prev.lib.filterAttrs (
                      name: _:
                      # we want to make our custom packages available in anything assuming nixpkgs
                      # we exclude "update" because that's the update script
                      # we also exclude all "-pkg" fake packages as those are just definitions
                        name != "update" && !(prev.lib.hasSuffix "-pkg" name)
                    )
                    self.packages.${config.nixpkgs.hostPlatform.system}
                )
              ];
            })
          ];
        };
      };
    };
}
