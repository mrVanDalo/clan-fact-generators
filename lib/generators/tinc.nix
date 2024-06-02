{ pkgs, lib, ... }:
with lib;
{

  tinc = { service ? "tinc", name ? "" }:
    let
      prefix = generatePrefix service name;
    in
    {
      secret."${prefix}.rsa_key.priv" = { };
      secret."${prefix}.ed25519_key.priv" = { };
      public."${prefix}.rsa_key.pub" = { };
      public."${prefix}.ed25519_key.pub" = { };
      generator.path = with pkgs; [
        coreutils
        tinc_pre
      ];
      generator.script = ''
        tinc --config "$secrets" generate-keys 4096 >/dev/null
        mv "$secrets"/rsa_key.priv     "$secrets"/${prefix}.rsa_key.priv
        mv "$secrets"/ed25519_key.priv "$secrets"/${prefix}.ed25519_key.priv
        mv "$secrets"/rsa_key.pub                     "$facts"/${prefix}.rsa_key.pub
        cat "$secrets"/ed25519_key.pub | tr -d '\n' > "$facts"/${prefix}.ed25519_key.pub
      '';
    };

}
