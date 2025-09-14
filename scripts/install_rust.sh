#i!/usr/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

rustup component add rust-src rust-analyzer

cargo install bindgen-cli --locked
