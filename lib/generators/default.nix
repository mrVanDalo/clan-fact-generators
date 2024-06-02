{ pkgs, ... }:
let
  lib = {
    generatePrefix = service: name:
      if name == "" then service else "${service}.${name}";
  };
in
{ }
// (import ./matrix-synapse.nix { inherit pkgs lib; })
// (import ./nix-serve.nix { inherit pkgs lib; })
// (import ./password.nix { inherit pkgs lib; })
// (import ./ssh.nix { inherit pkgs lib; })
// (import ./tinc.nix { inherit pkgs lib; })
  // (import ./wireguard.nix { inherit pkgs lib; })
