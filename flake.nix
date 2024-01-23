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
          distDir = ".deploy/deploy-server";
        };

        server-image = pkgs.dockerTools.buildImage {
          name = "pnpm-mono-server";
          tag = "latest";
          copyToRoot = [ pkgs.curl pkgs.coreutils server pkgs.bash ];
          config = {
            Cmd = [ "${pkgs.nodejs}" "${server}/dist/main/index.js" ];
          };
        };

        # Development environment
        devShell = mkShell {
          name = "pnpm-monorepo-test";
          nativeBuildInputs = [ nodejs typescript nodePackages.pnpm dive ed ];
        };

        packages = {
          inherit server server-image;
          default = server;
        };
      });
}
