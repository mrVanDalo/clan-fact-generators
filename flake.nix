{
  description = "clan.lol lib to standardize facts generation";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.nixpkgs.follows = "nixpkgs"; # Needed if your configuration uses nixpkgs unstable.
      inputs.flake-parts.follows = "flake-parts";
    };

  };

  outputs = inputs@{ flake-parts, clan-core, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        inputs.clan-core.flakeModules.default
      ];

      # Define your clan
      clan =
        let
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
          };
        in
        {
          # Clan wide settings. (Required)
          clanName = "test"; # Ensure to choose a unique name.
          specialArgs = {
            factGenerators = inputs.self.lib { inherit pkgs; };
          };
          machines = {
            test = { factGenerators, ... }: {
              imports = [ ];
              nixpkgs.hostPlatform = "x86_64-linux";
              # Set this for clan commands use ssh i.e. `clan machines update`
              clan.networking.targetHost = pkgs.lib.mkDefault "root@jon";
              # remote> lsblk --output NAME,ID-LINK,FSTYPE,SIZE,MOUNTPOINT
              disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4aec2929";

              # There needs to be exactly one controller per clan
              clan.networking.zerotier.controller.enable = false;
              clanCore.facts.secretStore = "password-store";
              clanCore.facts.publicDirectory = "/dev/null";

              # tests
              clanCore.facts.services.wireguard_a = factGenerators.wireguard { };
              clanCore.facts.services.wireguard_b = factGenerators.wireguard { name = "test"; };
              clanCore.facts.services.tinc_a = factGenerators.tinc { };
              clanCore.facts.services.tinc_b = factGenerators.tinc { name = "test"; };
              clanCore.facts.services.password_a = factGenerators.password { };
              clanCore.facts.services.password_b = factGenerators.password { name = "test"; };
              clanCore.facts.services.ssh_a = factGenerators.ssh { };
              clanCore.facts.services.ssh_b = factGenerators.ssh { name = "test"; };

            };
          };
        };


      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = pkgs.hello;

        # test fact generators creation
        apps.default = {
          type = "app";
          program = pkgs.writers.writeBashBin "test"
            ''
              export PASSWORD_STORE_DIR=$(mktemp -d)
              echo PASSWORD_STORE_DIR=$PASSWORD_STORE_DIR
              ${pkgs.pass}/bin/pass init 389EC2D64AC71EAC
              ${clan-core.packages.${system}.clan-cli}/bin/clan facts generate test
              ${clan-core.packages.${system}.clan-cli}/bin/clan facts list test
              pass list
              echo "deleting machines folder"
              rm -rf machines
            '';
        };

      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

        lib = import ./lib/generators.nix;
      };
    };
}
