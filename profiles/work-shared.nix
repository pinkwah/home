{ pkgs, ... }:

{
  imports = [ ./shared.nix ];

  programs.git = {
    settings.user.email = "ZOM@equinor.com";
    settings.user.name = "Zohar Malamant";
    signing.key = "449CA7BB72549B82";
    signing.signByDefault = false;
  };
}
