# Nix development and packaging (work in progress)

Tend targets **x86_64-linux** first, with **crate2nix 0.15** and one
Nix derivation per Rust crate. This does **not** use Crane or fall back to
`buildRustPackage`/one huge `cargo build` derivation.

> This is the initial Nix scaffold. A successful Nix build, a committed
> `flake.lock`, and Hyprland launch testing are still outstanding.

## Getting started

From a checkout of the `tend/dev` branch:

```fish
nix flake lock
```

```fish
git add flake.lock
```

```fish
nix develop
```

```fish
nom build .#tend
```

```fish
nix run .#tend
```

A `nix build` works too; `nom` is only the output-monitor frontend.
The first evaluation uses **import-from-derivation (IFD)** to generate
`Cargo.nix` from the locked Cargo workspace. The generated file is kept
in the Nix store, not committed to this repository. This allows dependency
changes without committing enormous generated Nix expressions. It can make
the first evaluation slower/less parallel, but still yields independently
cached per-crate build derivations.

## Outputs

- `packages.x86_64-linux.tend` / `packages.x86_64-linux.default`: wrapped desktop application.
- `apps.x86_64-linux.default`: launch the installed binary.
- `devShells.x86_64-linux.default`: Rust, `crate2nix`, `nom`, and GPUI's native libraries.
- `checks.x86_64-linux.tend-build`: build integration check.

The current package wraps upstream's `fern` binary as `tend` while
application-wide renaming remains on the roadmap. It does not package the
optional synchronization server.

## Fork safety

- Nix-managed launches export `TEND_NIX_MANAGED=1`. The application uses
  this to turn off the **original Fern self-updater**, without suppressing
  automatic data backups.
- Tend defaults to the separate XDG user-data directory
  `~/.local/share/tend` (or `$XDG_DATA_HOME/tend`). It does **not**
  move or open an existing `fern-tasks` directory by default.
- Do not rename or delete Fern's SQLite data manually. A separate,
  deliberate backup/import migration procedure is part of the branding milestone.
- Nix should own updates; do not run the original release updater on a Nix installation.

## CI and lockfile

`.github/workflows/nix.yml` regenerates the missing lockfile in CI and
uploads it as an artifact for review. **The repository must commit
`flake.lock` before Nix packaging is considered reproducible.**

The first CI build may expose GPUI or other native dependency issues.
Fix those with focused `crate2nix` overrides rather than replacing the
build system. No build success is claimed until verified.

## Existing Cargo workflow

Upstream Cargo builds/tests are unchanged and remain useful inside
`nix develop` for iteration. For the packaged release, the canonical
build should be `nix build .#tend`.
