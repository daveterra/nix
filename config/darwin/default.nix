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
    environment.systemPackages = [pkgs.pam-reattach];
  };
}
