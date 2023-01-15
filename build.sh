git add .
git commit --amend --no-edit
nix build --show-trace .#darwinConfigurations.Hal.system
