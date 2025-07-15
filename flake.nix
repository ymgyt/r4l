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
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          # Rust
          rustc
          rust-bindgen
          rustfmt
          clippy

          # LLVM toolchain (use stdenv for proper linking)
          llvmPackages.stdenv.cc
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

          export RUST_LIB_SRC="${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

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

          # Additional flags for special targets
          export KBUILD_CFLAGS="-Wno-unused-command-line-argument -Wno-error"
          export CFLAGS="-Wno-unused-command-line-argument -Wno-error"
          export CPPFLAGS="-Wno-unused-command-line-argument -Wno-error"
          export LDFLAGS="-Wno-unused-command-line-argument"

          # Override specific flags that cause errors
          export CFLAGS_REMOVE_unused_command_line_argument="-Werror=unused-command-line-argument"
          export HOSTCFLAGS_REMOVE_unused_command_line_argument="-Werror=unused-command-line-argument"

          # Realmode specific flags
          export REALMODE_CFLAGS="-m16 -g -Os -D__KERNEL__ -D_SETUP -D_WAKEUP -DDISABLE_BRANCH_PROFILING -Wall -Wstrict-prototypes -march=i386 -mregparm=3 -fno-strict-aliasing -fomit-frame-pointer -fno-pic -mno-mmx -mno-sse -Wno-unused-command-line-argument -Wno-error"

          # Use stdenv's properly configured compiler
          export CC="clang"
          export CXX="clang++"
          export HOSTCC="clang -Wno-unused-command-line-argument -Wno-error"
          export HOSTCXX="clang++ -Wno-unused-command-line-argument -Wno-error"

          # Override problematic flags
          export KBUILD_CFLAGS_KERNEL="\$KBUILD_CFLAGS_KERNEL -Wno-error=unused-command-line-argument"
          export KBUILD_AFLAGS="\$KBUILD_AFLAGS -Wno-error=unused-command-line-argument"

          # Additional LLVM tools with explicit paths
          export AR=${pkgs.llvmPackages.llvm}/bin/llvm-ar
          export NM=${pkgs.llvmPackages.llvm}/bin/llvm-nm
          export STRIP=${pkgs.llvmPackages.llvm}/bin/llvm-strip
          export OBJCOPY=${pkgs.llvmPackages.llvm}/bin/llvm-objcopy
          export OBJDUMP=${pkgs.llvmPackages.llvm}/bin/llvm-objdump
          export READELF=${pkgs.llvmPackages.llvm}/bin/llvm-readelf
          export LD=${pkgs.llvmPackages.lld}/bin/ld.lld
          export HOSTAR=${pkgs.llvmPackages.llvm}/bin/llvm-ar
          export HOSTLD=${pkgs.llvmPackages.lld}/bin/ld.lld

          echo "LLVM toolchain ready for make LLVM=1"
          echo "All warning suppressions configured"
        '';
      };
    };
}
