{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pnpm2nix.url = "github:nathanscully/pnpm2nix-nzbr";
  };

  outputs = { self, nixpkgs, flake-utils, pnpm2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        mkPnpmPackage = pnpm2nix.packages.${system}.mkPnpmPackage;
      in with pkgs; rec {
        server = mkPnpmPackage {
          src = ./.;
          installInPlace = true;
          copyNodeModules = true;
          copyPnpmStore = true;
          script = "deploy-server";
          distDir = "deploy-server";
        };

        # Development environment
        devShell = mkShell {
          name = "pnpm-monorepo-test";
          nativeBuildInputs = [ nodejs typescript nodePackages.pnpm ];
        };

        packages = {
          inherit server;
          default = server;
        };
      });
}
