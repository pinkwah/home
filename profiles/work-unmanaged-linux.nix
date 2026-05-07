{ lib, pkgs, ... }:

{
  imports = [ ./work-shared.nix ];

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
