{
  self,
  config,
  lib,
  pkgs,
  system,
  ...
}:
with lib; let
  cfg = config.dave.brew;
in {
  config = mkIf (pkgs.stdenv.isDarwin) {
    # homebrew.enable = true;
    # homebrew.onActivation.cleanup = true;
    # homebrew.casks = [
    #   {
    #     name = "nikitabobko/tap/aerospace";
    #   }
    # ];
  };
}
