# Cargo

## Cargo

Cargo is the Rust package manager. Cargo downloads your Rust package's dependencies, compiles your packages, makes distributable packages, and uploads them to `crates.io`, the Rust community's package registry.

## Cargo change mirror

`error: failed to fetch `https://github.com/rust-lang/crates.io-index`

```bash
# change to tsinghua mirror
vim ~/.cargo/config

# add lines below to config
[source.crates-io]
replace-with = 'tuna'

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
```
