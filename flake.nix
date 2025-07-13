{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      rustLibSrc = pkgs.rust.packages.stable.rustPlatform.rustLibSrc;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          rustc
          rust-bindgen
          rustfmt
          clippy
        ];
        shellHook = ''
          echo "RUST_LIB_SRC = ${rustLibSrc}"
        '';

        RUST_LIB_SRC = "${rustLibSrc}";
      };
    };
}
