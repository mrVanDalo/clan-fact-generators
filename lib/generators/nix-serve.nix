{ pkgs, lib, ... }:
with lib;
{

  # name must be set, such as cache.example.org-1. Is seen by client
  nix-serve = { service ? "nix-serve", name }:
    let
      prefix = generatePrefix service name;
    in
    {
      secret."${prefix}.key" = { };
      public."${prefix}.pub" = { };
      generator.path = with pkgs; [ coreutils nix ];
      generator.script = ''
        nix-store --generate-binary-cache-key "${prefix}" $secrets/${prefix}.key $facts/${prefix}.pub
      '';
    };
}
