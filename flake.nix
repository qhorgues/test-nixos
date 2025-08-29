{
  description = "Flake multi-arch avec pkgs et pkgs-unstable pour linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # version stable à adapter
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
      linuxSystems = [ "x86_64-linux" "aarch64-linux" "i686-linux" ];

      forAllSystems = f:
        builtins.listToAttrs (map (system: {
          name = system;
          value = f system;
        }) linuxSystems);
    in
    {
      legacyPackages = forAllSystems (system: {
        pkgs = import nixpkgs {
          inherit system;
        };
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
        };
      });
      # C’est ici qu’on expose un nixosSystem prêt à l’emploi
      nixosSystem = args:
        nixpkgs.lib.nixosSystem (
          args // {
            # injecter nixpkgs distant
            specialArgs = (args.specialArgs or {}) // {
              pkgs = import nixpkgs { system = args.system; };
              pkgs-unstable = import nixpkgs-unstable { system = args.system; };
            };
          }
        );

      lib = nixpkgs.lib;
    };
}
