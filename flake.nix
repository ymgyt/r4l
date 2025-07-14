{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

    in
    {
      devShells.${system}.default = pkgs.mkShell.override { stdenv = pkgs.llvmPackages.stdenv; } {
        nativeBuildInputs = with pkgs; [
          # Rust
          rustc
          rust-bindgen
          rustfmt
          clippy

          # LLVM toolchain
          llvmPackages.clang
          llvmPackages.llvm
          llvmPackages.lld
          glibc.dev

          # Kernel build deps
          elfutils
          ncurses
          pkg-config
          bison
          flex
          bc
          openssl.dev
          kmod
          perl
          python3

          # Build tools
          gnumake
          which
          findutils
          gawk
          rsync
        ];
        shellHook = ''
          echo "Setting up Rust for Linux environment..."

          # LLVM/Clang setup
          export LIBCLANG_PATH=${pkgs.libclang.lib}/lib
          export LD_LIBRARY_PATH=${pkgs.libclang.lib}/lib:$${LD_LIBRARY_PATH:-}

          # Kernel build environment for LLVM
          export LLVM=1

          # Comprehensive warning suppression for all build stages
          export KCFLAGS="-Wno-unused-command-line-argument -Wno-address-of-packed-member -Wno-error"
          export KAFLAGS="-Wno-unused-command-line-argument -Wno-error"
          export HOSTCFLAGS="-Wno-unused-command-line-argument -Wno-error -isystem ${pkgs.glibc.dev}/include"
          export KBUILD_CFLAGS_KERNEL="-Wno-unused-command-line-argument -Wno-error"
          export KBUILD_CFLAGS_MODULE="-Wno-unused-command-line-argument -Wno-error"
          export CFLAGS_KERNEL="-Wno-unused-command-line-argument -Wno-error"
          export CFLAGS_MODULE="-Wno-unused-command-line-argument -Wno-error"

          # Host compiler setup with system headers
          export HOSTCC="clang -isystem ${pkgs.glibc.dev}/include -isystem ${pkgs.llvmPackages.clang-unwrapped}/lib/clang/*/include -Wno-unused-command-line-argument -Wno-error"
          export HOSTCXX="clang++ -isystem ${pkgs.glibc.dev}/include -isystem ${pkgs.llvmPackages.clang-unwrapped}/lib/clang/*/include -Wno-unused-command-line-argument -Wno-error"

          # Additional LLVM tools
          export AR=llvm-ar
          export NM=llvm-nm
          export STRIP=llvm-strip
          export OBJCOPY=llvm-objcopy
          export OBJDUMP=llvm-objdump
          export READELF=llvm-readelf
          export LD=ld.lld
          export HOSTAR=llvm-ar
          export HOSTLD=ld.lld

          echo "LLVM toolchain ready for make LLVM=1"
          echo "All warning suppressions configured"
        '';
      };
    };
}
