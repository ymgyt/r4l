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
      llvm = pkgs.llvmPackages_19;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [

          # LLVM
          llvm.clang
          llvm.libclang.lib

          # Kernel build deps
          elfutils
          ncurses
          pkg-config
          bison
          flex
          bc
        ];
        shellHook = ''
          echo "libclang = ${llvm.libclang.lib}"
          export LIBCLANG_PATH=${llvm.libclang.lib}/lib
          export LD_LIBRARY_PATH=${llvm.libclang.lib}/lib:$${LD_LIBRARY_PATH:-}
          export WERROR=0
          export EXTRA_AFLAGS="-Wno-error=unused-command-line-argument"

          export LLVM_IAS=0
        '';

        HOSTCFLAGS = "-Wno-error=unused-command-line-argument";
        KCFLAGS = "-Wno-error=unused-command-line-argument -Wno-error=address-of-packed-member";
      };
    };
}
