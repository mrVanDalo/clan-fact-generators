{ pkgs, lib, ... }:
with lib;
{

  syncthing = { service ? "syncthing", name ? "" }:
    let
      prefix = generatePrefix service name;
    in
    {
      secret."${prefix}.key" = { };
      secret."${prefix}.cert" = { };
      public."${prefix}.pub" = { };
      generator.path = with pkgs; [
        coreutils
        gnugrep
        syncthing
      ];
      generator.script = ''
        syncthing generate --config "$secrets"
        mv "$secrets"/key.pem "$secrets"/${prefix}.key
        mv "$secrets"/cert.pem "$secrets"/${prefix}.cert
        cat "$secrets"/config.xml | grep -oP '(?<=<device id=")[^"]+' | uniq > "$facts"/${prefix}.pub
      '';
    };

}
