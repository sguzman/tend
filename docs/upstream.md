# Upstream maintenance

Tend is a maintained fork of [atabits/fern](https://github.com/atabits/fern).

## Baseline

As checked on **2026-11-18**, the unchanged fork's `main` branch
and upstream Fern's `main` both pointed to:

```text
880a3237d3bdfe6ab1c3f14ce6c42c4052629a9e
```

This is the baseline for the Tend development and branding changes.
The default branch remains reserved for upstream tracking; Tend changes
are developed on `tend/dev` and short-lived topic branches.

## Updating from Fern

For a local checkout, configure the remotes once:

```fish
git remote add upstream https://github.com/atabits/fern.git
```

Fetch new upstream history without changing a local branch:

```fish
git fetch upstream
```

Review source changes, the release notes, and especially database migrations,
GPUI dependency changes, and security fixes. Make a new maintenance branch
from the current Tend development branch, integrate upstream there, and run
Cargo and Nix checks before proposing a merge.

**Do not force-push** the Tend development branches or automatically merge
upstream into `main`. Prefer small, reviewable changes; any rebases
across shared branches require an explicit coordinated decision.

## Priorities during upstream review

- Security fixes and SQLite schema/data migrations.
- Native GPUI/Wayland compatibility, Zed Git dependency updates and Rust versions.
- Changes to Cargo.lock that require regenerating `Cargo.nix` with crate2nix.
- Upstream changes to the updater, release workflow, settings/data paths,
  backup/restore, icon/title and custom application IDs.
- AGPL attribution and copyright notices.

The goal is an easily maintained fork—not a permanent freeze or an
unreviewable independent rewrite.

## Dependency changes

After updating Cargo manifests or locks, regenerate and review the
committed per-crate Nix graph:

```fish
nix develop --command crate2nix generate -f Cargo.toml -o Cargo.nix
```

Then build in a Nix environment, review CI results, and validate a
real Tend desktop launch before updating the Home Manager deployment.
For data-migration versions, take a backup first and do not assume a
downgrade remains possible.

## Releases

The inherited Fern release workflow is deliberately guarded so it
cannot publish original Fern-branded binaries from `sguzman/tend`.
Nix-managed desktop installations must not self-update by downloading
upstream releases. Independent Tend releases remain out of scope until
packaging, branding and test coverage are complete.
