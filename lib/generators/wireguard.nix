{ pkgs, lib, ... }:
with lib;
{

  wireguard = { service ? "wireguard", name ? "" }:
    let
      prefix = generatePrefix service name;
    in
    {
      secret."${prefix}.key" = { };
      public."${prefix}.pub" = { };
      generator.path = with pkgs; [
        coreutils
        wireguard-tools
      ];
      generator.script = ''
        wg genkey > "$secrets"/${prefix}.key
        cat "$secrets"/${prefix}.key | wg pubkey > "$facts"/${prefix}.pub
      '';
    };

}
