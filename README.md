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
  clanCore.facts.services.wireguard = factsGenerator.wireguard {};
  clanCore.facts.services.tinc = factsGenerator.tinc {};
  clanCore.facts.services.password = factsGenerator.password { name = "palo"; };
  clanCore.facts.services.ssh_host = factsGenerator.ssh { name = "host"; };
  clanCore.facts.services.ssh_borg = factsGenerator.ssh { name = "borg"; };
};
```

> Every `factsGenerator` accepts a `name` (usually optional) parameter and `service` (optional) parameter to
> change the secret name.

