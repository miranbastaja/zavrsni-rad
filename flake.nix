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

      perSystem = {pkgs, ...}: let
        srcfile = "main.typ";
        outfile = "Završni rad.pdf";
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "zavrsni-rad";
          version = "0.0.1";
          src = ./.;
          buildInputs = [pkgs.typst];
          buildPhase = ''
            typst $srcfile "$outfile"
          '';
          installPhase = ''
            source $stdenv/setup
            mkdir -p "$out"
            mv "$outfile" "$out/"
          '';
        };

        devshells.default = {
          name = "zavrsni-sh";

            commands = [
            { package = pkgs.lazygit; }
            {
              name = "build";
              help = "Compile the typst code into a PDF";
              category = "development";
              command = ''
                ${pkgs.typst}/bin/typst ${srcfile} "${outfile}"
              '';
            }
            {
              name = "develop";
              help = "Watch the inputs and recompile the PDF on changes";
              category = "development";
              command = ''
                ${pkgs.typst}/bin/typst --watch ${srcfile} "${outfile}"
              '';
            }
            {
              name = "clean";
              help = "Clean up build results";
              category = "development";
              command = ''
                rm "${outfile}"
              '';
            }
          ];
        };
      }; # end of perSystem
    }; # end of flake-parts.lib.mkFlake
}
