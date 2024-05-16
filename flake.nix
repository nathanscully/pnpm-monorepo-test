{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nathanscully.url = "github:nathanscully/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nathanscully,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlay = final: prev: {
          # Inherit the changes into the overlay
          inherit (nathanscully.legacyPackages.${system}) nodePackages;
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      with pkgs;
      rec {
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
