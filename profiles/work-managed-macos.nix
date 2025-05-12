{ lib, pkgs, ... }:
{
  imports = [ ./work-shared.nix ];

  programs.gpg.enable = true;
  programs.doom-emacs.emacs = lib.mkForce (pkgs.emacs30.override { withNativeCompilation = false; });
}
