{ config, lib, pkgs, profile, ... }:

# Declarative Pi and Forge configuration.
#
# Pi is packaged as a fetchurl derivation from the official GitHub release
# tarballs, which contain a self-contained binary (no Node.js or Bun needed).
# The tarball also bundles themes, docs, wasm, and export assets; these are
# installed alongside the binary so PI_PACKAGE_DIR can point to the derivation
# output and Pi can find them at runtime.
#
# Pi settings.json is a read-only Nix store symlink — use home-manager
# switch to change settings; Pi's /settings TUI will not persist changes.
#
# To upgrade Pi: bump piVersion + update both sha256 hashes below, then
# run darwin-rebuild switch. Get hashes with:
#   nix-prefetch-url --type sha256 \
#     https://github.com/earendil-works/pi/releases/download/vVER/pi-darwin-arm64.tar.gz
#
# Forge agents and commands are placed as individual home.file symlinks
# inside the existing mutable ~/.forge/ directory, which also holds
# credentials, conversation history, and logs that must stay mutable.

let
  isServer = profile == "server";
  isWork   = profile == "work";

  # ── Pi binary derivation ──────────────────────────────────────────────────
  # Release tarballs contain a self-contained Bun-compiled binary plus
  # bundled assets (themes, wasm, export-html, docs, examples).
  # PI_PACKAGE_DIR is set to $out so Pi resolves theme/dark.json etc.
  # correctly when the binary is stored at a Nix store path.
  piVersion = "0.74.0";

  piPlatform = {
    "aarch64-darwin" = {
      tarball = "darwin-arm64";
      sha256  = "042yn7c7fk7i87fiwrp6gxpk292h05bhq90j8diqbaf64fc1fqrh";
    };
    "x86_64-darwin" = {
      tarball = "darwin-x64";
      sha256  = "0q3mrjx2m1kqy6i628qhkfy4fycqkgfa7a5ikzwc47k55j7wjrgs";
    };
  }.${pkgs.stdenv.hostPlatform.system};

  piPkg = pkgs.stdenv.mkDerivation {
    pname   = "pi-coding-agent";
    version = piVersion;

    src = pkgs.fetchurl {
      url    = "https://github.com/earendil-works/pi/releases/download/v${piVersion}/pi-${piPlatform.tarball}.tar.gz";
      sha256 = piPlatform.sha256;
    };

    dontBuild     = true;
    dontConfigure = true;
    dontFixup     = true; # skip patchelf/strip — binary is pre-signed

    installPhase = ''
      runHook preInstall

      # stdenv auto-cds into the single top-level `pi/` directory during
      # unpackPhase, so all paths here are relative to that extracted dir.
      #
      # Pi resolves ALL assets (package.json, theme/, wasm, etc.) relative to
      # the binary's own directory.  Install everything into $out/bin/ so the
      # layout mirrors the original tarball and PI_PACKAGE_DIR=$out/bin works.
      mkdir -p $out/bin
      install -m755 pi $out/bin/pi

      cp -r theme       $out/bin/theme
      cp -r export-html $out/bin/export-html
      cp -r docs        $out/bin/docs
      cp -r examples    $out/bin/examples
      cp    photon_rs_bg.wasm $out/bin/photon_rs_bg.wasm
      cp    package.json      $out/bin/package.json

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Pi coding agent — terminal AI pair programmer";
      homepage    = "https://pi.dev";
      platforms   = [ "aarch64-darwin" "x86_64-darwin" ];
      mainProgram = "pi";
    };
  };

  # ── Pi settings.json ──────────────────────────────────────────────────────
  # Provider and model are conditioned on profile so the same module works on
  # both machines without any per-machine override.
  #
  # Work:     Bedrock via the existing `bedrock` AWS SSO profile.
  #           Run `aws sso login --profile bedrock` before first use.
  #
  # Personal: Anthropic direct. Set ANTHROPIC_API_KEY in the shell.
  piSettings = {
    defaultProvider = if isWork then "bedrock" else "anthropic";
    defaultModel    = if isWork
                        then "anthropic.claude-sonnet-4-6"
                        else "claude-sonnet-4-20250514";

    # Extensions, skills, and prompts are resolved at runtime from these paths.
    # xdg.configFile entries below place Nix-managed content here.
    extensions = [ "${config.xdg.configHome}/ai/pi/extensions" ];
    skills     = [ "${config.xdg.configHome}/ai/pi/skills"     ];
    prompts    = [ "${config.xdg.configHome}/ai/pi/prompts"    ];

    enableInstallTelemetry = false;

    compaction = {
      enabled          = true;
      reserveTokens    = 16384;
      keepRecentTokens = 20000;
    };

    retry = {
      enabled    = true;
      maxRetries = 3;
    };
  };

in
lib.mkIf (!isServer) {

  # ── Packages ───────────────────────────────────────────────────────────────
  # Pi is a self-contained binary — no Node.js or Bun required.
  home.packages = [ piPkg ];

  # ── Environment variables ─────────────────────────────────────────────────
  home.sessionVariables = {
    # Point Pi at its bundled assets (themes, wasm, export-html).
    # Pi resolves assets relative to the binary, so PI_PACKAGE_DIR must
    # point to $out/bin where everything is co-located.
    PI_PACKAGE_DIR = "${piPkg}/bin";

    # Redirect Pi session storage to a mutable path outside the Nix store.
    # Documented in Pi v0.71.0 as the environment-variable equivalent of
    # the --session-dir flag.
    PI_CODING_AGENT_SESSION_DIR =
      "${config.home.homeDirectory}/.pi/sessions";
  };

  # ── Pi: settings.json ─────────────────────────────────────────────────────
  # Read-only symlink to the Nix store. Pi's /settings TUI will not be able
  # to write here — change settings in this file and run darwin-rebuild switch.
  home.file.".pi/agent/settings.json".text = builtins.toJSON piSettings;

  # ── Pi: extensions, AGENTS.md ─────────────────────────────────────────────
  # Directory source creates a single symlink at the target path pointing to
  # the Nix store directory. Pi scans extensions/ for .ts files at startup.
  xdg.configFile = {
    "ai/pi/extensions".source = ./pi/extensions;
    "ai/pi/AGENTS.md".source  = ./pi/AGENTS.md;
    # Skills and prompts directories: populate by adding files to
    # home/pi/skills/ and home/pi/prompts/ and re-running darwin-rebuild switch.
  };

  # ── Forge: custom agents and commands ─────────────────────────────────────
  # Individual symlinks within the existing mutable ~/.forge/ directory.
  # ~/.forge/.forge.toml, .credentials.json, and .forge.db remain mutable.
  home.file = {
    ".forge/agents/pi-delegate.md".source = ./forge/agents/pi-delegate.md;
    ".forge/commands/check.md".source     = ./forge/commands/check.md;
  };

  # ── Activation: ensure mutable session directory exists ───────────────────
  home.activation.aiAgentDirs =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "${config.home.homeDirectory}/.pi/sessions"
    '';
}
