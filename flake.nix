{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in with pkgs; rec {
        # Development environment
        devShell = mkShell {
          name = "pnpm-monorepo-test";
          nativeBuildInputs = [ nodejs typescript nodePackages.pnpm  ];
        };
      }
    );
}
