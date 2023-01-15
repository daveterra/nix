{ pkgs, lib, inputs, ... }: {
  time.timeZone = "America/Los_Angeles";
  # networking.hostName = inputs.hostname;
  nix = {
    package = pkgs.nix;
    registry.nixpkgs.flake = inputs.stable;
    extraOptions = ''
      warn-dirty = false
      experimental-features = nix-command flakes
      build-users-group = nixbld
      sandbox = true
    '';
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      # replaceStdenv = { pkgs }: pkgs.nativeMoldyRustyClangStdenv;
    };
  };
}
