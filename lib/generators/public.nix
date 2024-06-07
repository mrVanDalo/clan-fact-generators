{ pkgs, lib, ... }:
with lib;
{

  # define public facts in code
  public = nameValues:
    {
      public = mapAttrs (_name: value: { }) nameValues;
      generator.path = with pkgs; [ coreutils ];
      generator.script =
        let
          a = mapAttrsToList
            (name: value: ''
              echo -n "${value}" > $facts/${name}
            '')
            nameValues;
        in
        concatStringsSep "\n" a;
    };

}
