{
  description = "Gunnar's system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		forgecode = {
      url = "github:tailcallhq/forgecode";
		};

		forgecode-sso = {
			url = "github:tailcallhq/forgecode/937ac6ef5b4f9668472c25f074a198f4149e41e2";
		};
    
		direnv-instant.url = "github:Mic92/direnv-instant";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
  {
    # ── macOS (nix-darwin) ─────────────────────────────────────────────
    darwinConfigurations."Gunnars-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [
        ./hosts/darwin-common.nix
        ./hosts/macbook-pro.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.gunnar = import ./home;
          home-manager.extraSpecialArgs = {
            profile = "personal";
						inherit inputs;
          };
        }
      ];
    };

    darwinConfigurations."C7FMV7W2R0" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/darwin-common.nix
        ./hosts/macbook-work.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.gunnar = import ./home;
          home-manager.extraSpecialArgs = {
            profile = "work";
						inherit inputs;
          };
        }
      ];
    };

    # ── Linux / homelab (NixOS) — uncomment when ready ─────────────────
    # nixosConfigurations."homelab-01" = nixpkgs.lib.nixosSystem {
    #   system = "x86_64-linux";
    #   modules = [
    #     { nixpkgs.overlays = overlays; }
    #     ./hosts/linux-common.nix
    #     ./hosts/homelab-01.nix
    #     home-manager.nixosModules.home-manager
    #     {
    #       home-manager.useGlobalPkgs = true;
    #       home-manager.useUserPackages = true;
    #       home-manager.users.gunnar = import ./home;
    #       home-manager.extraSpecialArgs = {
    #         profile = "server";
    #       };
    #     }
    #   ];
    # };
  };
}
