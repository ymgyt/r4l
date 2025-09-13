# Nix development environment for Rust-for-Linux

```sh
nix develop github:ymgyt/r4l -c $env.SHELL

git clone https://github.com/Rust-for-Linux/linux.git r4l-linux
cd r4l-linux

make LLVM=1 rustavailable
```

## References

* [docs.kernel.org/rust/quick-start.html#nix](https://docs.kernel.org/rust/quick-start.html#nix)
