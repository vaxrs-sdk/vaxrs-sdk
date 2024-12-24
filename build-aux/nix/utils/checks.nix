{
  system,
  inputs,
  lib,
  ...
}:
inputs.git-hooks.lib.${system}.run {
  src = lib.cleanSource ./.;
  hooks = {
    deadnix.enable = true;
    statix = {
      enable = true;
      settings.ignore = [".direnv" ".devenv.*" ".devenv"];
    };
    alejandra.enable = true;
    prettier.enable = true;
    yamlfmt.enable = true;
    actionlint.enable = true;
    rustfmt.enable = true;
  };
}
