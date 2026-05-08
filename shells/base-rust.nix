{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    # rustup manages the actual toolchain; projects pin their version
    # via rust-toolchain.toml so we don't hardcode a channel here.
    rustup
  ];

  shellHook = ''
    # rust-analyzer should be installed via rustup to match the active toolchain:
    #   rustup component add rust-analyzer
  '';
}
