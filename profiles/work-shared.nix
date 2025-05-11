{ pkgs, ... }:

{
  includes = [ ./shared.nix ];

  programs.git = {
    userEmail = "ZOM@equinor.com";
    userName = "Zohar Malamant";
    signing.key = "449CA7BB72549B82";
    signByDefault = true;
  };

  home.packages = with pkgs; [ azure-cli ];
}
