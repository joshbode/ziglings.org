{
  description = "ziglings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    {
      systems,
      nixpkgs,
      zig,
      zls,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      zig-version = "master";

      overlays = [
        (final: prev: {
          zig-pkgs = zig.packages.${prev.system};
          zls-pkgs = zls.packages.${prev.system};
        })
      ];

      eachSystem =
        f:
        lib.genAttrs (import systems) (
          system:
          f (
            import nixpkgs {
              inherit system overlays;
            }
          )
        );
    in
    {
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            zig-pkgs.${zig-version}
            zls-pkgs.zls
          ];
        };
      });
    };
}
