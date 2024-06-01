DRY facts generator lib for [clan](https://clan.lol)

## How to import in your flake

```nix
clan = {
  specialArgs = {
    factGenerators = clan-fact-generators.lib { inherit pkgs; };
  };
};
```

## How to use

Now you can use the predefined generators

```nix
{ factGenerators , ... }:
with factGenerators;
{
  clanCore.facts.services.wireguard = factGenerators.wireguard "test";
  clanCore.facts.services.tinc = factGenerators.tinc "test";
  clanCore.facts.services.password = factGenerators.password "test";
  clanCore.facts.services.ssh = factGenerators.ssh "test";
};
```

