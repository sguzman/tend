# Tend — Linux runtime QA

This records verified observations separately from outstanding checks for the
`tend/branding` branch. It is **not** an installation or migration guide.

## Verified on 2026-11-18

- x86_64-linux `crate2nix` build, flake checks, and committed graph freshness
  passed on [GitHub Actions](https://github.com/sguzman/tend/actions/runs/44364040674).
- On EndeavourOS + Hyprland + NVIDIA RTX 3090, the packaged application opened
  with the Tend title, dark UI and initial tasks. Its Nix launcher appends
  `/usr/lib` for access to Arch's host Vulkan ICD libraries. This
  compatibility path is intentionally **non-NixOS-specific**, not a general
  substitute for Home Manager GPU integration.
- A subsequent local `nom build .#tend` rebuilt only the application crate and
  Tend wrapper (two derivations); dependencies were cached independently.
- Using a disposable `TEND_DATA_DIR`, the user created a `Tend QA` task,
  edited its notes, added four subtasks, closed the application, and reopened
  the same profile. The task and four-subtask count persisted.
- Linux and Windows Cargo builds/tests passed. The macOS job was cancelled,
  rather than producing a reported compiler error.

## Test principles

- Do not open, copy over, or delete a real Fern profile.
- Always use a disposable Tend directory, and **reuse the same directory**
  when checking persistence. Repeatedly using `mktemp` creates a fresh profile.
- Keep the original source profile untouched during backup/restore testing.
- A passing Rust unit test does not establish that a desktop notification,
  clipboard, or native file chooser works under Hyprland.
- Do not update `main`, package a server, or enable the inherited self-updater
  for QA. This project remains Linux-first and feature-frozen.

## Remaining interactive tests

### A. Deep link (command-line dispatch; no system registration)

1. While the disposable-profile Tend window is open, select the QA task and
   choose **More → Copy Link** in its task detail menu.
2. Check that the clipboard contains `tend://task/<UUID>`.
3. Close Tend to avoid testing two writers against the same SQLite profile.
4. From the checked-out repository, launch the built package with that copied
   link as an argument and `TEND_DATA_DIR` pointing to the **same** directory.
   For fish on Wayland, if `wl-paste` is installed:

   ```fish
   env TEND_DATA_DIR=/path/to/the/same/qa-profile ./result/bin/tend (wl-paste --no-newline)
   ```

5. Verify the linked task opens in the details pane. The source accepts both
   `tend://task/<UUID>` and legacy `fern://task/<UUID>` arguments.

**Separate integration check:** `xdg-open tend://...` needs the desktop file
installed and registered as the scheme handler. The package includes that
metadata, but direct command-line success alone does not prove `xdg-open`.

### B. Desktop reminders

In Tend **Settings → Notifications**, enable desktop reminders. Create a
disposable task with a due time a few minutes ahead and a reminder due at that
time. Leave Tend running and verify both a Mako notification and the in-app
notification bell. The reminder loop checks approximately every 20 seconds.
Do not set or test reminders in a real profile.

### C. Backup export and restore (fresh *second* profile)

1. With the original QA profile active, use **Settings → About → Generate
   Backup** and export outside either profile. Keep the exported `.db` file.
2. Start Tend with a **different**, empty, disposable `TEND_DATA_DIR`.
3. Use **Settings → About → Import Backups**, select the exported `.db`
   file, then close and reopen with that same second directory.
4. Check task titles, notes, four subtasks and any sample attachments.
   The first QA profile must be unchanged.
5. Do not test Fern-to-Tend migration with valuable data until the disposable
   Tend-to-Tend roundtrip is proven.

## Still out of scope or pending

- Keyboard/focus across multiple windows, scaling, drag-and-drop, and file
  chooser behavior remain to be checked as needed.
- Home Manager deployment in the separate configuration repository is pending
  and must not be confused with this successful local Nix package test.
- Native macOS/Windows installers, upstream syncing, and standalone releases
  remain separate decisions.
