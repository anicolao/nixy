{
  description = "Project Nixy: Cloud Desktop Proof of Concept";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.nixy-gce = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"
        ./configuration.nix
      ];
    };
  };
}
