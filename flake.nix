{
  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix, flake-compat }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        overlays = [ haskellNix.overlay (final: prev: {
          flakeProject = final.haskell-nix.project' {
            src = ./.;
            compiler-nix-name = "ghc924";
            shell.tools = {
              cabal = {};
              hlint = {};
              haskell-language-server = {};
            };
            shell.buildInputs = with pkgs; [
              openssl.dev llvmPackages_14.llvm.dev
            ];
          };
        }) ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.flakeProject.flake { };
      in flake // {
        packages.default = flake.packages."day-one:exe:day-one".override(self: {
          enableDeadCodeElimination = true;
          dontStrip = false;
        });
      });

    nixConfig = {
      extra-substituters = ["https://cache.iog.io"];
      extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
      allow-import-from-derivation = "true";
    };
}
