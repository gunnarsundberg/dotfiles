{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    python3
    uv   # fast Python package/project manager
  ];
}
