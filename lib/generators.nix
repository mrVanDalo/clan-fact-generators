{ pkgs, ... }:
let
  generatePrefix = service: name:
    if name == "" then service else "${service}.${name}";
in
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
        mv "$secrets"/rsa_key.priv "$secrets"/${prefix}.rsa_key.priv
        mv "$secrets"/ed25519_key.priv "$secrets"/${prefix}.ed25519_key.priv
        mv "$secrets"/rsa_key.pub "$facts"/${prefix}.rsa_key.pub
        mv "$secrets"/ed25519_key.pub "$facts"/${prefix}.ed25519_key.pub
      '';
    };

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

  nix-serve = { service ? "nix-serve", name ? "" }:
    let
      prefix = generatePrefix service name;
    in
    {
      secret."${prefix}.key" = { };
      public."${prefix}.pub" = { };
      generator.path = with pkgs; [ coreutils nix ];
      generator.script = ''
        nix-store --generate-binary-cache-key "$secrets"/${prefix}.key "$facts"/${prefix}.pub
      '';
    };

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

  ssh = { service ? "ssh", name ? "" }:
    let
      prefix = generatePrefix service name;
    in
    {
      secret."${prefix}.id_ed25519" = { };
      public."${prefix}.id_ed25519.pub" = { };
      generator.path = with pkgs; [ coreutils openssh ];
      generator.script = ''
        ssh-keygen -t ed25519 -N "" -f $secrets/${prefix}.id_ed25519
        mv $secrets/${prefix}.id_ed25519.pub $facts/${prefix}.id_ed25519.pub
      '';
    };


  matrix-synapse = { service ? "tinc", name ? "" }:
    let
      prefix = generatePrefix service name;
    in
    {
      secret."synapse-registration_shared_secret" = { };
      generator.path = with pkgs; [ coreutils pwgen ];
      generator.script = ''
        echo "registration_shared_secret: $(pwgen -s 32 1)" > "$secrets"/${prefix}
      '';
    };

}
