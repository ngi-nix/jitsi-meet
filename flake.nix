{
  description = "A flake for jitsi-meet";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";


    npmlock2nix-repo = {
      url = "github:tshaynik/npmlock2nix/fetchgit2";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, npmlock2nix-repo }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
  {
    overlay = final: prev:
      let
        npmlock2nix = import npmlock2nix-repo { pkgs = prev; } //
         {nodejs = pkgs.nodejs-12_x;};
      in
    {
      my-jitsi-meet = npmlock2nix.build {
        src = ./.;
        buildCommands = [
          "npm run build"
          "make"
        ];
        installPhase = "cp -r dist $out";
      };
    };

    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = [
        pkgs.nodejs-12_x
      ];
    };

    packages.x86_64-linux.my-jitsi-meet =
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ self.overlay ]; };
    in
      pkgs.my-jitsi-meet;

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.my-jitsi-meet;
  };
}