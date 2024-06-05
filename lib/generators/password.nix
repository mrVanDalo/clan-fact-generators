{ pkgs, lib, ... }:
with lib;
{

  password = { service ? "password", name ? "", phrases ? 4 }:
    let
      prefix = generatePrefix service name;
    in
    {
      secret."${prefix}" = { };
      secret."${prefix}.pam" = { };
      generator.path = with pkgs; [ coreutils xkcdpass mkpasswd ];
      generator.script = ''
        xkcdpass -n ${toString phrases} -d - > $secrets/${prefix}
        cat $secrets/${prefix} | mkpasswd -s -m sha-512 > $secrets/${prefix}.pam
      '';
    };

}
