{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    go
    gopls
    gotools       # goimports, godoc, etc.
    golangci-lint
  ];
}
