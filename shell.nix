let
  pkgs =
    import (
      fetchTarball (
        builtins.fromJSON (
          builtins.readFile ./nixpkgs.json
        )
      )
    ) {
    };
in
  pkgs.mkShell {
    packages = [
      pkgs.alejandra
      pkgs.bashInteractive
      pkgs.cacert
      pkgs.gitFull
      pkgs.gitlint
      pkgs.gnumake
      pkgs.nix
      pkgs.nixos-rebuild
      pkgs.nodePackages.prettier
      pkgs.pre-commit
    ];
  }
