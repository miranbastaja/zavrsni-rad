{
  inputs = {
    #FIXME: change nixpkgs url to nixos-unstable branch when typst gets added
    #       and maybe change it to a stable branch when one with typst gets
    #       released
    nixpkgs.url = "github:nixos/nixpkgs/master";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = ["x86_64-linux"];
      imports = [
        inputs.devshell.flakeModule
      ];
      perSystem = {pkgs, ...}: {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "zavrsni-rad";
          version = "0.0.1";
          src = ./.;
          buildInputs = [pkgs.typst];
          buildPhase = ''
            typst main.typ "Završni rad.pdf"
          '';
          installPhase = ''
            source $stdenv/setup
            mkdir -p "$out"
            mv "Završni rad.pdf" "$out/"
          '';
        };

        devshells.default = {
          name = "zavrsni-sh";

          commands = [
            { package = pkgs.typst; }
            { package = pkgs.lazygit; }
          ];
        };
      }; # end of perSystem
    }; # end of flake-parts.lib.mkFlake
}
