{
  description = "Tend — native task management, packaged crate-by-crate with crate2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    crate2nix.url = "github:nix-community/crate2nix/0.15.0";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, crate2nix, rust-overlay, ... }:
    let
      # Scope the initial package to the actual target machine. Other platforms
      # remain on upstream Cargo CI until tested with Nix.
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };
      lib = pkgs.lib;
      rustToolchain = pkgs.rust-bin.stable.latest.default;

      # GPUI loads Vulkan/GL and several system libraries dynamically.
      # Native crate overrides give the build scripts headers and pkg-config
      # data; the launcher provides the required shared libraries at runtime.
      gpuiLibraries = with pkgs; [
        wayland
        libxkbcommon
        vulkan-loader
        fontconfig
        freetype
        libglvnd
        xorg.libX11
        xorg.libxcb
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXi
        xorg.libXext
      ];
      nativeBuildInputs = with pkgs; [
        pkg-config
        wayland-protocols
      ];

      withNativeLibraries = _attrs: {
        inherit nativeBuildInputs;
        buildInputs = gpuiLibraries;
      };

      # crate2nix invokes this for each crate. It does NOT call cargo build
      # for the entire workspace or use Crane.
      buildRustCrateForPkgs = p: p.buildRustCrate.override {
        rustc = rustToolchain;
        cargo = rustToolchain;
        defaultCrateOverrides = p.defaultCrateOverrides // {
          gpui = withNativeLibraries;
          gpui_platform = withNativeLibraries;
          fern_desktop = withNativeLibraries;
        };
      };

      # Generate Cargo.nix on demand (IFD). Keep Cargo.lock in version control
      # and commit flake.lock before considering the package reproducible.
      generatedCargoNix = crate2nix.tools.${system}.generatedCargoNix {
        name = "tend";
        src = ./.;
      };
      cargoNix = import generatedCargoNix {
        inherit pkgs buildRustCrateForPkgs;
      };
      desktop = cargoNix.workspaceMembers.fern_desktop.build;

      tend = pkgs.runCommand "tend-0.1.11" {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      } ''
        mkdir -p "$out/bin" "$out/share/applications" "$out/share/icons/hicolor/256x256/apps"

        # Binary is still called fern internally until the branding milestone.
        # Tend's wrapper isolates data and opts out of the upstream auto-updater.
        makeWrapper "${desktop}/bin/fern" "$out/bin/tend" \
          --set TEND_NIX_MANAGED 1 \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath gpuiLibraries}"

        install -m644 ${./assets/icon/icon-256.png} "$out/share/icons/hicolor/256x256/apps/tend.png"
        cat > "$out/share/applications/tend.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Tend
Comment=Native task manager
Exec=tend
Icon=tend
Terminal=false
Categories=Office;ProjectManagement;
EOF
      '';
    in
    {
      packages.${system}.tend = tend;
      packages.${system}.default = tend;

      apps.${system}.default = {
        type = "app";
        program = "${tend}/bin/tend";
      };
      apps.${system}.tend = self.apps.${system}.default;

      checks.${system}.tend-build = tend;

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          rustToolchain
          pkgs.pkg-config
          pkgs.crate2nix
          pkgs.nix-output-monitor
        ] ++ gpuiLibraries ++ [ pkgs.wayland-protocols ];
      };
    };
}
