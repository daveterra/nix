{
  self,
  config,
  lib,
  pkgs,
  system,
  ...
}:
with lib; let
  cfg = config.dave.darwin;

  aerospace = pkgs.stdenv.mkDerivation {
    name = "aerospace";
    version = "0.11.2-Beta";
    src = pkgs.fetchzip {
      url = "https://github.com/nikitabobko/AeroSpace/releases/download/v0.11.2-Beta/AeroSpace-v0.11.2-Beta.zip";
      hash = "sha256-S1jrkU+ovi4KuBPLg59SV0OSx2mhXebT+GKfVb8m/aE=";
    };

    unpackPhase = ''
      echo $src
      ls -lah $src/
      mkdir $out
      mkdir -p $out/Applications
      cp -r $src/AeroSpace.app $out/Applications
      cp -r $src/ $out/
    '';
  };
in {
  imports = [./pam.nix ./brew.nix];
  config = mkIf (pkgs.stdenv.isDarwin) {
    system.keyboard.enableKeyMapping = true;
    system.keyboard.remapCapsLockToEscape = true;

    system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;

    system.defaults.finder.ShowPathbar = true;
    system.defaults.finder.AppleShowAllFiles = true;
    system.defaults.finder.QuitMenuItem = true;
    system.defaults.finder.ShowStatusBar = true;

    system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
    system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;

    system.defaults.dock.autohide = true;
    system.defaults.dock.magnification = false;
    system.defaults.dock.persistent-apps = ["DevToys" "KiCad" "Hammerspoon" "Overcast"];
    # Show only open applications in the Dock. The default is false.
    # system.defaults.dock.static-only

    system.defaults.menuExtraClock.ShowDayOfMonth = true;
    system.defaults.menuExtraClock.ShowDayOfWeek = true;

    security.pam.enableSudoTouchIdAuth = true;
    environment.systemPackages = [pkgs.pam-reattach pkgs.kitty];

    # Nix-darwin does not link installed applications to the user environment. This means apps will not show up
    # in spotlight, and when launched through the dock they come with a terminal window. This is a workaround.
    # Upstream issue: https://github.com/LnL7/nix-darwin/issues/214
    # system.activationScripts.applications.text = lib.mkForce ''
    #   echo "setting up ~/Applications..." >&2
    #   applications="$HOME/Applications"
    #   nix_apps="$applications/Nix Apps"

    #   # Needs to be writable by the user so that home-manager can symlink into it
    #   if ! test -d "$applications"; then
    #       mkdir -p "$applications"
    #       chown dave: "$applications"
    #       chmod u+w "$applications"
    #   fi

    #   # Delete the directory to remove old links
    #   rm -rf "$nix_apps"
    #   mkdir -p "$nix_apps"
    #   find ${config.system.build.applications}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
    #       while read src; do
    #           # Spotlight does not recognize symlinks, it will ignore directory we link to the applications folder.
    #           # It does understand MacOS aliases though, a unique filesystem feature. Sadly they cannot be created
    #           # from bash (as far as I know), so we use the oh-so-great Apple Script instead.
    #           /usr/bin/osascript -e "
    #               set fileToAlias to POSIX file \"$src\"
    #               set applicationsFolder to POSIX file \"$nix_apps\"
    #               tell application \"Finder\"
    #                   make alias file to fileToAlias at applicationsFolder
    #                   # This renames the alias; 'mpv.app alias' -> 'mpv.app'
    #                   set name of result to \"$(rev <<< "$src" | cut -d'/' -f1 | rev)\"
    #               end tell
    #           " 1>/dev/null
    #       done
    # '';
  };
}
