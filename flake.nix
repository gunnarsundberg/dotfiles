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
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, forgecode, ... }:
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
						inherit forgecode;
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
						inherit forgecode;
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
