{
  self,
  config,
  lib,
  pkgs,
  system,
  ...
}:
with lib; let
  cfg = config.dave.helix;
in {
  options = {
    dave.helix = {
      enabled = mkOption {
        description = ''
          Enable Helix editor and some common language servers
        '';
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf (cfg.enabled) {
    environment.systemPackages = with pkgs; [
      # Helix and LSPs
      alejandra # Nix formatter
      dprint # Markdown formatter (also json, toml?)
      unstable.helix
      marksman
      nodePackages_latest.bash-language-server
      nodePackages_latest.vscode-langservers-extracted
      pkgs.unstable.typos-lsp
      python310Packages.python-lsp-server
      # rnix-lsp
      rust-analyzer
      rustfmt
      swift-format
      typos
    ];
  };
}
