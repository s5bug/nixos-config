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
      };
      flake = {
        nixosConfigurations.hydrogen = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [./configuration.nix];
        };
      };
    };
}
