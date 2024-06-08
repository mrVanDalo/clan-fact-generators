{ pkgs, lib, ... }:
with lib;
{

  zfs = { service ? "zfs", name ? "" }:
    let
      prefix = generatePrefix service name;
    in
    {
      public."${prefix}.hostId" = { };
      generator.path = with pkgs; [
        coreutils
      ];
      generator.script = ''
        head -c4 /dev/urandom | od -A none -t x4 | tr -d ' ' | tr -d '\n' > "$facts"/${prefix}.hostId
      '';
    };

}
