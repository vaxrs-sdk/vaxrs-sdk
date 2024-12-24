{
  description = "A Rust set of tools/libraries for interacting with XR/AR/VR devices on multiple platforms.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nix-github-actions.url = "github:shymega/nix-github-actions?ref=shymega-patch";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    substituters = [
      "https://vaxrs-sdk.cachix.org?priority=10"
      "https://cache.nixos.org?priority=15"
    ];
    trusted-public-keys = [
      "vaxrs-sdk.cachix.org-1:8TUmFwJXdC+5DeEpk8x39gU/musU5RwzyXxbDkXSlNY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  outputs = {self, ...} @ inputs: let
    genPkgs = system:
      import inputs.nixpkgs {
        inherit system;
      };

    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

    treeFmtEachSystem = f: inputs.nixpkgs.lib.genAttrs systems (system: f (genPkgs system));
    treeFmtEval = treeFmtEachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./build-aux/nix/utils/formatter.nix);

    eachDefaultSystem = f: inputs.nixpkgs.lib.genAttrs systems (system: f (genPkgs system));
  in
    {
      packages = eachDefaultSystem (pkgs: {
        vaxrs-lib = pkgs.callPackage ./build-aux/nix/vaxrs-lib.nix {inherit self;};
        default = self.packages.${pkgs.system}.vaxrs-lib;
      });

      # use flake-parts
      devShells =
        eachDefaultSystem
        (
          pkgs: {
            default =
              pkgs.buildFHSUserEnv
              {
                name = "vaxrs-devenv";
                targetPkgs = pkgs:
                  with pkgs;
                    [
                      cargo
                      clippy
                      cmake
                      gcc
                      git
                      glibc
                      pkg-config
                      rustc
                      rustfmt
                      rustup
                    ]
                    ++ pkgs.lib.singleton self.packages.${pkgs.system}.vaxrs-lib;
              };
          }
        );
    }
    // {
      overlays.default = final: _prev: {
        inherit (self.packages.${final.system}) vaxrs-lib;
      };

      githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
        # Enable support for arm64 Linux + armv7l/armv6l.
        checks =
          inputs.nixpkgs.lib.getAttrs [
            "x86_64-linux"
            "aarch64-linux"
          ]
          self.checks;
      };
      checks = treeFmtEachSystem (pkgs: {
        formatting = treeFmtEval.${pkgs.system}.config.build.wrapper;
      });

      formatter = treeFmtEachSystem (pkgs: treeFmtEval.${pkgs.system}.config.build.wrapper);
    };
}
