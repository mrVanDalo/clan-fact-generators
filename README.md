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
  clanCore.facts.services.wireguard = factsGenerator.wireguard "test";
  clanCore.facts.services.tinc = factsGenerator.tinc "test";
  clanCore.facts.services.password = factsGenerator.password "test";
  clanCore.facts.services.ssh = factsGenerator.ssh "test";
};
```

