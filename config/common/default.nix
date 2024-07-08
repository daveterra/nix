{
  config,
  lib,
  pkgs,
  system,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./helix.nix
  ];

  nixpkgs.overlays = [outputs.overlays.unstable-packages];

  services.nix-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    # Command line tools
    # bash # Needed for tmux/extracto, also just nice to have newer version
    # ncdu # Better du -csh
    aspell
    aspellDicts.en
    atuin
    base16-builder
    bat # replaces cat
    bitwarden-cli
    btop # Fancier top with disk and net usage
    direnv
    direnv
    docker-compose
    du-dust
    entr # Do something when files change
    eza # replaces ls
    fish
    flavours
    frogmouth # Markdown reader
    fswatch
    fzf
    git
    git-crypt
    inetutils
    jq # Json tool
    lazygit
    ltex-ls
    nix
    nmap
    pv
    restic # Backup util
    ripgrep
    rsync
    silver-searcher # ag
    starship
    tmux
    tmuxinator
    tree
    walk # Util for browsing folders
    wget
    zoxide # replaces cd

    # Taskwarrior things...
    unstable.taskwarrior3
    unstable.taskwarrior-tui
    tasksh
    vit

    # Fun-like utils
    neofetch
    lolcat
    cowsay
    figlet
    unstable.boxes
    asciiquarium
    cbonsai
    # graph-easy

    # Other dev, though this should all be local...
    nodejs
    yarn
    arduino-cli
  ];

  programs.fish.enable = true;
  programs.fish.loginShellInit = ''
    ## XXX(Xe): unfuck nix-ld
    eval (cat /etc/set-environment | grep NIX_LD)
  '';

  # boot.tmp.cleanOnBoot = true;
  # boot.kernelModules = [ "wireguard" ];
  # boot.binfmt.emulatedSystems =
  #   [ "wasm32-wasi" "aarch64-linux" "riscv64-linux" ];
  # security.polkit.enable = true;

  # services.prometheus.exporters.node.enable = true;
  # services.prometheus.exporters.node.enabledCollectors = [ "systemd" ];

  # services.journald.extraConfig = ''
  #   SystemMaxUse=100M
  #   MaxFileSec=7day
  # '';

  # services.resolved = {
  #   enable = true;
  #   dnssec = "false";
  # };

  nix = {
    package = pkgs.nixVersions.stable;
    # package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      auto-optimise-store = true;
      sandbox = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://djt.cachix.org"
      ];
      trusted-users = ["root" "dave"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "djt.cachix.org-1:VF6a7Gm3YV13DtcRSoojVO+ZZOuS1ScOCcN/0ESJdGg="
      ];
    };
  };

  # system.stateVersion = (if pkgs.stdenv.isDarwin == "aarch64-darwin" then 4 else "23.11");
}
