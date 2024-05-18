{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nathanscully.url = "github:nathanscully/nixpkgs";
    fetchPnpmDeps.url = "github:scrumplex/nixpkgs/pkgs/build-support/fetchPnpmDeps";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nathanscully,
      fetchPnpmDeps,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlay = final: prev: {
          # Inherit the changes into the overlay
          inherit (nathanscully.legacyPackages.${system}) nodePackages;
          inherit (fetchPnpmDeps.legacyPackages.${system}) fetchPnpmDeps2;
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };

        server = pkgs.stdenv.mkDerivation (finalAttrs: {
          pname = "server";
          name = "server";
          src = ./.;
          version = "1.0.0";
          pnpmDeps = pkgs.fetchPnpmDeps2 {
            inherit (finalAttrs) pname version src;
            hash = "sha256-Gr69KbhDSFCfTZnb7Cyjv3rs2ZAnu8M1foTbRr+sMzI=";
          };

          nativeBuildInputs = [ pkgs.fetchPnpmDeps2.pnpmConfigHook ];
          doCheck = false;

          postBuild = ''
            pnpm run --filter server... build
            pnpm --offline --frozen-lockfile --ignore-script --filter server --prod deploy server-deploy
          '';
          installPhase = ''
            cp -r server-deploy $out
          '';
        });

        frontend = pkgs.stdenv.mkDerivation (finalAttrs: {
          pname = "frontend";
          name = "frontend";
          src = ./.;
          version = "1.0.0";
          pnpmDeps = pkgs.fetchPnpmDeps2 {
            inherit (finalAttrs) pname version src;
            hash = "sha256-Gr69KbhDSFCfTZnb7Cyjv3rs2ZAnu8M1foTbRr+sMzI=";
          };

          nativeBuildInputs = [ pkgs.fetchPnpmDeps2.pnpmConfigHook ];
          doCheck = false;

          postBuild = ''
            pnpm run --filter frontend... build
            pnpm --offline --frozen-lockfile  --ignore-script --filter frontend --prod  deploy frontend-deploy
          '';

          # pnpm --offline --frozen-lockfile  --ignore-script --filter frontend --prod  deploy frontend-deploy
          installPhase = ''
            cp -r frontend-deploy $out
          '';
        });
      in
      with pkgs;
      rec {
        packages = {
          inherit server frontend;
        };
        # Development environment
        devShell = mkShell {
          name = "pnpm-monorepo-test";
          nativeBuildInputs = [
            nodejs
            typescript
            nodePackages.pnpm
            turbo
            nixpacks
          ];
        };
      }
    );
}
