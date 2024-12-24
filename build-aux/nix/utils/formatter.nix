{pkgs, ...}: {
  package = pkgs.treefmt;
  projectRootFile = "flake.nix";

  settings = {
    global.excludes = [
      ".direnv"
      ".devenv.*"
      ".devenv"
    ];
    shellcheck.includes = [
      "*.sh"
      ".envrc"
    ];
  };
  programs = {
    deadnix.enable = true;
    statix.enable = true;
    alejandra.enable = true;
    prettier.enable = true;
    yamlfmt.enable = true;
    jsonfmt.enable = true;
    mdformat.enable = true;
    actionlint.enable = true;
  };
}
