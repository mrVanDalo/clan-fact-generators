> Deprecated in favor of [clan-vars-generator](https://github.com/mrVanDalo/clan-vars-generator/tree/main)

DRY facts generator lib for [clan](https://clan.lol)

## How to import in your flake

```nix
clan = {
  specialArgs = {
    factsGenerator = clan-fact-generators.lib { inherit pkgs; };
  };
};
```

## How to use

Now you can use the predefined generators

```nix
{ factsGenerator , ... }:
with factsGenerator;
{
  clan.core.facts.services.wireguard = factsGenerator.wireguard {};
  clan.core.facts.services.tinc = factsGenerator.tinc {};
  clan.core.facts.services.password = factsGenerator.password { name = "palo"; };
  clan.core.facts.services.ssh_host = factsGenerator.ssh { name = "host"; };
  clan.core.facts.services.ssh_borg = factsGenerator.ssh { name = "borg"; };
};
```

> Every `factsGenerator` accepts a `name` (usually optional) parameter and `service` (optional) parameter to
> change the secret name.

