{ pkgs, lib, ... }:
with lib;
{
  tor =
    { service ? "tor"
    , name ? ""
    , addressPrefix ? "clan"
    }:
    let
      prefix = generatePrefix service name;
      filter = if (name != "") && (addressPrefix == "clan") then name else addressPrefix;
    in
    {
      secret."${prefix}.priv" = { };
      secret."${prefix}.hostname" = { };
      generator.path = with pkgs; [
        coreutils
        mkp224o
      ];
      generator.script = ''
        mkp224o-donna ${filter} -n 1 -d . -q -O addr
        mv "$(cat addr)"/hs_ed25519_secret_key "$secrets"/${prefix}.priv
        mv addr "$secrets"/${prefix}.hostname
      '';
    };


}
