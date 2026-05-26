{ pkgs, fenix }:
let
  toolchain = fenix.stable.withComponents [
    "cargo"
    "clippy"
    "rustc"
    "rustfmt"
    "rust-src"
    "rust-analyzer"
  ];
in
pkgs.mkShell {
  packages = [ toolchain ];
}
