{ lib, pkgs, ... }:
{
  imports = [ ./work-shared.nix ];

  programs.gpg.enable = true;
}
