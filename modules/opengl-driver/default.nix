{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (pkgs) zenity;
  inherit (pkgs.stdenv) isLinux;
  cfg = config.opengl-driver;

  setup = pkgs.writeShellScript "opengl-driver-setup" ''
    rm -f /nix/var/nix/profiles/opengl-driver
    nix build ${inputs.nixpkgs}#mesa -o /nix/var/nix/profiles/opengl-driver

    tmpfile=/etc/tmpfiles.d/nix-opengl-driver.conf
    if [[ ! -e "$tmpfile" ]]
    then
      echo "L+ /run/opengl-driver - - - - /nix/var/nix/profiles/opengl-driver" > "$tmpfile"
      systemd-tmpfiles --create "$tmpfile"
    fi
  '';

  check = pkgs.writeShellScript "opengl-driver-check" ''
    alias jq=${pkgs.jq}/bin/jq

    if [[ ! -e "/run/opengl-driver" ]]
    then
      echo "/run/opengl-driver doesn't exist. Starting pkexec"
      /usr/bin/pkexec /bin/sh --login "${setup}"
    else
      echo "/run/opengl-driver already exists"
    fi
  '';

in
{
  options.opengl-driver = {
    enable = lib.mkEnableOption "opengl-driver";
  };

  config = lib.mkIf (cfg.enable && isLinux) {
    systemd.user.services.nix-opengl-driver = {
      Unit = {
        Description = "Setup OpenGL on non-NixOS Linux";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${check}";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
