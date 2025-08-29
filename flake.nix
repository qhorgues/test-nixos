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
      nixosSystem = { system, modules ? [], specialArgs ? {} }:
        let
          baseModules = import "${nixpkgs}/nixos/modules/module-list.nix";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ modules;
          specialArgs = specialArgs // {
            pkgs = import nixpkgs { inherit system; };
            pkgs-unstable = import nixpkgs-unstable { inherit system; };
          };
        };

      lib = nixpkgs.lib;
    };
}
