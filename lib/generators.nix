{ pkgs, ... }:
{

  # generate tinc keys.
  tinc = name: {
    secret."tinc.${name}.rsa_key.priv" = { };
    secret."tinc.${name}.ed25519_key.priv" = { };
    public."tinc.${name}.rsa_key.pub" = { };
    public."tinc.${name}.ed25519_key.pub" = { };
    generator.path = with pkgs; [
      coreutils
      tinc_pre
    ];
    generator.script = ''
      tinc --config "$secrets" generate-keys 4096 >/dev/null
      mv "$secrets"/rsa_key.priv "$secrets"/tinc.${name}.rsa_key.priv
      mv "$secrets"/ed25519_key.priv "$secrets"/tinc.${name}.ed25519_key.priv
      mv "$secrets"/rsa_key.pub "$facts"/tinc.${name}.rsa_key.pub
      mv "$secrets"/ed25519_key.pub "$facts"/tinc.${name}.ed25519_key.pub
    '';
  };

  # generate wireguard keys
  wireguard = name: {
    secret."wireguard.${name}.key" = { };
    public."wireguard.${name}.pub" = { };
    generator.path = with pkgs; [
      coreutils
      wireguard-tools
    ];
    generator.script = ''
      wg genkey > "$secrets"/wireguard.${name}.key
      cat "$secrets"/wireguard.${name}.key | wg pubkey > "$facts"/wireguard.${name}.pub
    '';
  };

  # nix-serve
  # generate private key with:
  # nix-store --generate-binary-cache-key my-secret-key my-public-key
  nix-serve = name: {
    secret."nix-serve.${name}.key" = { };
    public."nix-serve.${name}.pub" = { };
    generator.path = with pkgs; [ coreutils nix ];
    generator.script = ''
      nix-store --generate-binary-cache-key "$secrets"/nix-serve.${name}.key "$facts"/nix-serve.${name}.pub
    '';
  };

  # generate password
  password = name: {
    secret."password.${name}" = { };
    secret."password.${name}.hash" = { };
    generator.path = with pkgs; [ coreutils xkcdpass mkpasswd ];
    generator.script = ''
      xkcdpass -n 4 -d - > $secrets/password.${name}
      cat $secrets/password.${name} | mkpasswd -s -m sha-512 > $secrets/password.${name}.hash
    '';
  };

  # ssh key (user and hostkey)
  ssh = name: {
    secret."ssh.${name}.id_ed25519" = { };
    public."ssh.${name}.id_ed25519.pub" = { };
    generator.path = with pkgs; [ coreutils openssh ];
    generator.script = ''
      ssh-keygen -t ed25519 -N "" -f $secrets/ssh.${name}.id_ed25519
      mv $secrets/ssh.${name}.id_ed25519.pub $facts/ssh.${name}.id_ed25519.pub
    '';
  };


  matrix-synapse = {
    secret."synapse-registration_shared_secret" = { };
    generator.path = with pkgs; [ coreutils pwgen ];
    generator.script = ''
      echo "registration_shared_secret: $(pwgen -s 32 1)" > "$secrets"/synapse-registration_shared_secret
    '';
  };

}
