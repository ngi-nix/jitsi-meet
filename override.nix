{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
}:

(import ./default.nix {
  pkgs = import nixpkgs { inherit system; };
  inherit system;
}).package.override {
  postInstall = ''
    patchShebangs node_modules
    npm run package
  '';
}
