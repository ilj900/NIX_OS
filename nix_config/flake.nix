{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      vulkanShell = import ./vulkan.nix { inherit pkgs; };
      hipShell    = import ./hip.nix    { inherit pkgs; };
    in {
      nixosConfigurations.ExMachina = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit vulkanShell hipShell; };
        modules = [ ./configuration.nix ];
      };
      
      devShells.${system} = {
        vulkan  = vulkanShell;
        default = vulkanShell;
        hip = hipShell;
      };
    };
}
