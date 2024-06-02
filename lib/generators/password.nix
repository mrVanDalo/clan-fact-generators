{ pkgs, lib, ... }:
with lib;
{

  password = { service ? "password", name ? "" }:
    let
      prefix = generatePrefix service name;
    in
    {
      secret."${prefix}" = { };
      secret."${prefix}.hash" = { };
      generator.path = with pkgs; [ coreutils xkcdpass mkpasswd ];
      generator.script = ''
        xkcdpass -n 4 -d - > $secrets/${prefix}
        cat $secrets/${prefix} | mkpasswd -s -m sha-512 > $secrets/${prefix}.hash
      '';
    };

}
