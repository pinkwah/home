{ pkgs, ... }:

{
  imports = [ ./shared.nix ];

  programs.git = {
    userEmail = "ZOM@equinor.com";
    userName = "Zohar Malamant";
    signing.key = "449CA7BB72549B82";
    signing.signByDefault = false;
  };

  home.packages = with pkgs; [ (azure-cli.withExtensions [azure-cli-extensions.application-insights]) ];
}
