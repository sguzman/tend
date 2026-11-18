# Tend

**A quiet, native place for tasks, projects and plans.**

Tend is a personally maintained fork of [Fern](https://github.com/atabits/fern), a
Rust/[GPUI](https://github.com/zed-industries/zed) desktop task manager.
It runs locally without an account or an Electron/WebView runtime.

> **Status:** early fork, still being packaged and rebranded. The application
> currently inherits much of Fern's UI, features and internal identifiers.
> No new product features are planned for the first milestone.

## What it does

All the existing features below come from Fern:

- Tasks, lists/projects, subtasks, priorities and tags
- Smart views, saved filters and Kanban boards
- Calendar, recurrence, reminders and task notes
- Habits, focus timers, an Eisenhower matrix and statistics
- Local SQLite persistence, attachments and daily backups
- Optional cross-device synchronization using a self-hosted server

Tend's immediate development scope is **reproducible Nix packaging** and a
**distinct application identity**, not rewriting Fern's task engine.

## Nix development

The initial Nix target is `x86_64-linux`, with per-crate builds via
[`crate2nix`](https://github.com/nix-community/crate2nix), not Crane.

```fish
nix flake lock
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

This integration is **in progress** and not yet claimed to build successfully.
Before relying on the package, follow the results in
[the roadmap](ROADMAP.md), the [Nix guide](docs/nix.md), and the development
branch's CI checks.

Upstream also supports ordinary `cargo` builds:

```fish
cargo run --release -p fern_desktop
```

Internal crate identifiers still use Fern names to limit merge conflicts.

## Local data and backups

The Tend desktop uses `$XDG_DATA_HOME/tend` (typically
`~/.local/share/tend`) for its SQLite database, attachments and backups.
It intentionally does not import, rename or overwrite the original
`~/.local/share/fern-tasks` directory.

Daily automatic backups remain part of the inherited application. Back up
anything important before testing major schema changes or importing data.

Nix-managed builds disable the original Fern self-updater; updates belong
to the user's Nix configuration.

## Fork maintenance

The original [Fern repository](https://github.com/atabits/fern) remains the
upstream. Tend aims to keep downstream changes small, preserve compatibility
where practical, and integrate upstream fixes after review. The original
project's authorship is not claimed as Tend's authorship.

See [ROADMAP.md](ROADMAP.md) for outstanding work. New features will be
considered only after using the application and identifying concrete needs.

## License and credits

Tend is based on **Fern**, originally developed by
[Amin Atabiev / atabits](https://github.com/atabits).
The work is distributed under **AGPL-3.0-or-later**, preserving upstream
copyright and attribution requirements. See [LICENSE](LICENSE) and the
original project's notices.

Fern itself documents how its functionality and design were developed
independently from TickTick, and credits third-party resources including
Lucide icons and IBM Plex fonts. Tend likewise has no affiliation with
TickTick, Fern's maintainers, or the Zed developers.
