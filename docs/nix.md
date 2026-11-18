# Nix development and packaging (in validation)

Tend targets **x86_64-linux** first, with **crate2nix 0.15.0** and
one Nix derivation per Rust crate. It does **not** use Crane or fall back to
a single `cargo build` derivation.

> The base `tend/dev` branch passed `nix build`, `nix flake check`,
> crate2nix graph freshness, and Cargo CI on November 18, 2026.
> The branded branch still needs integration CI and a running GUI check
> on the actual Hyprland/NVIDIA machine before release.

## Build and run

From the development branch:

```fish
nix develop
```

```fish
nom build .#tend
```

```fish
nix run .#tend
```

`nom` is the preferred Nix output monitor, not a separate builder.

## Regenerate the per-crate graph

`Cargo.nix` and `flake.lock` are committed. After a deliberate change to
`Cargo.toml` or `Cargo.lock`, run:

```fish
nix develop --command crate2nix generate -f Cargo.toml -o Cargo.nix
```

Review and commit the generated `Cargo.nix` alongside the Cargo dependency
changes. Only update `flake.lock` when changing Nix inputs:

```fish
nix flake lock
```

**Why is `Cargo.nix` committed?** The automatic import-from-derivation
path attempted to vendor nested GPUI/Zed Git workspace crates and failed
because a crate inherited edition metadata from a workspace root that was
not included in the vendored source. Generation from the intact Cargo
workspace succeeded in CI, so the checked-in graph avoids that IFD
vendoring problem while retaining per-crate builds and Nix caching.

The Nix flake imports that graph directly. No alternate Rust build system
has been substituted.

## Outputs

- `packages.x86_64-linux.tend` / `packages.x86_64-linux.default`: wrapped desktop application.
- `apps.x86_64-linux.default`: launches Tend.
- `devShells.x86_64-linux.default`: Rust, `crate2nix`, `nom`, GPUI native dependencies.
- `checks.x86_64-linux.tend-build`: package build integration check.

The sync server is not packaged. Internal Cargo crate names still match Fern
until renaming becomes worth the upstream merge cost.

## Data and update safety

- Nix-managed launches export `TEND_NIX_MANAGED=1` to disable the
  **original Fern self-updater**, without suppressing daily backups.
- Tend defaults to the separate XDG data directory
  `~/.local/share/tend` (or `$XDG_DATA_HOME/tend`).
- An existing `fern-tasks` data directory is **not** moved, deleted, or
  opened by default. Migrating tasks is a separate, explicit import operation.
- Nix owns binary updates; the app must not overwrite its own executable
  in `/nix/store`.

## Verification

The base branch passed `nix build .#tend` and `nix flake check`.
The combined branding changes must pass the same checks before merging. Also verify the generated dependency graph against the committed
`Cargo.nix`, then test launch, fonts, notifications, scaling, persistence,
and backups under Hyprland/Wayland on the actual NVIDIA machine.

The first GNOME/Wayland desktop entry and icon have been added to the fork,
but a local running-app QA pass is still required.
