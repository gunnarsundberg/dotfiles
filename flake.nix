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

    direnv-instant.url = "github:Mic92/direnv-instant";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
  let
    supportedSystems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in
  {
    # ── Reusable modules (consumed by work-dotfiles) ───────────────────
    darwinModules.common = ./hosts/darwin-common.nix;
    homeModules.base     = ./home;

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

    # ── Base dev shells (composable via inputsFrom in work-dotfiles) ───
    devShells = forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        base-go     = import ./shells/base-go.nix     { inherit pkgs; };
        base-rust   = import ./shells/base-rust.nix   { inherit pkgs; };
        base-python = import ./shells/base-python.nix { inherit pkgs; };
      }
    );
  };
}
