{ pkgs, ... }:
let
  lib = pkgs.lib // {
    generatePrefix = service: name:
      if name == "" then service else "${service}.${name}";
  };
in
{ }
// (import ./matrix-synapse.nix { inherit pkgs lib; })
// (import ./nix-serve.nix { inherit pkgs lib; })
// (import ./password.nix { inherit pkgs lib; })
// (import ./public.nix { inherit pkgs lib; })
// (import ./ssh.nix { inherit pkgs lib; })
// (import ./syncthing.nix { inherit pkgs lib; })
// (import ./tinc.nix { inherit pkgs lib; })
// (import ./tor.nix { inherit pkgs lib; })
// (import ./wireguard.nix { inherit pkgs lib; })
  // (import ./zfs.nix { inherit pkgs lib; })
