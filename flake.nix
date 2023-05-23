{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        inputs.devshell.flakeModule
        inputs.pre-commit-hooks.flakeModule
      ];

      perSystem = {
        pkgs,
        config,
        ...
      }: let
        srcfile = "main.typ";
        outfile = "Završni rad.pdf";
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "zavrsni-rad";
          version = "1.0.0";
          src = ./.;
          buildInputs = [pkgs.typst];
          buildPhase = ''
            typst compile ${srcfile} "${outfile}"
          '';
          installPhase = ''
            source $stdenv/setup
            mkdir -p "$out"
            mv "${outfile}" "$out/"
          '';
        };

        devshells.default = {
          name = "zavrsni-sh";
          devshell.startup.pre-commit-install.text =
            config.pre-commit.installationScript;

          commands = [
            {package = pkgs.lazygit;}
            {package = pkgs.typst;}
            {
              name = "build";
              help = "Compile the typst code into a PDF";
              category = "development";
              command = ''
                ${pkgs.typst}/bin/typst compile ${srcfile} "${outfile}"
              '';
            }
            {
              name = "develop";
              help = "Watch the inputs and recompile the PDF on changes";
              category = "development";
              command = ''
                ${pkgs.typst}/bin/typst watch ${srcfile} "${outfile}"
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
        }; # end of devshells.default

        formatter = pkgs.alejandra;
        pre-commit = {
          check.enable = true;
          settings.hooks = {
            alejandra.enable = true;
            statix.enable = true;
            deadnix.enable = true;
          };
        }; # end of pre-commit
      }; # end of perSystem
    }; # end of flake-parts.lib.mkFlake
}
