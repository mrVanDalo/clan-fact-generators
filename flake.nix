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
          pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        in
        {
          # Clan wide settings. (Required)
          clanName = "test"; # Ensure to choose a unique name.
          specialArgs = {
            factsGenerator = inputs.self.lib { inherit pkgs; };
          };
          machines = {
            test = { factsGenerator, ... }: {
              imports = [ ];
              nixpkgs.hostPlatform = "x86_64-linux";
              # Set this for clan commands use ssh i.e. `clan machines update`
              clan.core.networking.targetHost = pkgs.lib.mkDefault "root@jon";
              # remote> lsblk --output NAME,ID-LINK,FSTYPE,SIZE,MOUNTPOINT
              disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4aec2929";

              # There needs to be exactly one controller per clan
              clan.core.networking.zerotier.controller.enable = false;
              clanCore.facts.secretStore = "password-store";
              clanCore.facts.publicDirectory = "/dev/null";

              # tests
              clanCore.facts.services.wireguard_a = factsGenerator.wireguard { };
              clanCore.facts.services.wireguard_b = factsGenerator.wireguard { name = "test"; };

              clanCore.facts.services.public = factsGenerator.public { ip = "1.2.3.4"; cidr = "1.2.3.4/24"; };

              clanCore.facts.services.tinc_a = factsGenerator.tinc { };
              clanCore.facts.services.tinc_b = factsGenerator.tinc { name = "test"; };

              clanCore.facts.services.password_a = factsGenerator.password { };
              clanCore.facts.services.password_b = factsGenerator.password { name = "test"; phrases = 10; };

              clanCore.facts.services.ssh_a = factsGenerator.ssh { };
              clanCore.facts.services.ssh_b = factsGenerator.ssh { name = "test"; };

              clanCore.facts.services.matrix_synapse_a = factsGenerator.matrix-synapse { };
              clanCore.facts.services.matrix_synapse_b = factsGenerator.matrix-synapse { name = "test"; };

              clanCore.facts.services.syncthing_a = factsGenerator.syncthing { };
              clanCore.facts.services.syncthing_b = factsGenerator.syncthing { name = "test"; };

              clanCore.facts.services.tor_a = factsGenerator.tor { };
              clanCore.facts.services.tor_b = factsGenerator.tor { name = "test"; };
              clanCore.facts.services.tor_c = factsGenerator.tor { name = "test"; };

              clanCore.facts.services.zfs = factsGenerator.zfs { };

              # not working
              # clanCore.facts.services.nix_serve_b = factsGenerator.nix-serve { name = "test.org"; };

            };
          };
        };


      perSystem = { config, self', inputs', pkgs, system, ... }: {

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = pkgs.hello;

        devShells.default = pkgs.mkShell {
          packages = [
            clan-core.packages.${system}.clan-cli
          ];
        };

        # test fact generators creation
        apps.default = {
          type = "app";
          program = pkgs.writers.writeBashBin "test"
            ''
              export PASSWORD_STORE_DIR=$(mktemp -d)
              echo PASSWORD_STORE_DIR=$PASSWORD_STORE_DIR
              ${pkgs.pass}/bin/pass init 389EC2D64AC71EAC
              ${clan-core.packages.${system}.clan-cli}/bin/clan facts generate test
              ${clan-core.packages.${system}.clan-cli}/bin/clan facts list test | ${pkgs.gojq}/bin/gojq
              echo export PASSWORD_STORE_DIR=$PASSWORD_STORE_DIR
              pass list
              echo "deleting machines folder"
              rm -rf machines
            '';
        };

      };
      flake = {
        lib = import ./lib/generators;
      };
    };
}
