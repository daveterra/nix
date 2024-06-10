{ self, config, lib, pkgs, system, ... }:
{
  config.dave.linux-builder = { 
    enabled = true;
    enableConfig = true;
  };

  config.security.pam.enableCustomSudoTouchIdAuth = true;
}
