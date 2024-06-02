{ pkgs, lib, ... }:
with lib;
{

  matrix-synapse = { service ? "matrix-synapse", name ? "" }:
    let
      prefix = generatePrefix service name;
    in
    {
      secret."${prefix}.registration_shared_secret.yml" = { };
      generator.path = with pkgs; [ coreutils pwgen ];
      generator.script = ''
        echo "registration_shared_secret: $(pwgen -s 32 1)" > "$secrets"/${prefix}.registration_shared_secret.yml
      '';
    };

}
