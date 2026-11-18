# Moving existing Fern data to Tend (optional)

Tend uses a **separate data directory** from Fern. A normal Tend launch must
not rewrite, delete, or move the original Fern profile.

This is a **manual, opt-in** operation only for someone who already uses Fern.
If Tend is a fresh install, there is nothing to migrate.

> **Status:** The procedure below reflects Fern's existing backup/restore UI
> and Tend's current storage layout. It has not yet passed a complete
> GUI-to-GUI migration test. Do not delete the Fern installation or its
> backups until that test and a personal verification are complete.

## Data locations on Linux

- Fern: `$XDG_DATA_HOME/fern-tasks` (normally `~/.local/share/fern-tasks`)
- Tend: `$XDG_DATA_HOME/tend` (normally `~/.local/share/tend`)

Each contains a SQLite `tasks.db` and may contain attachments, backups,
and other application data. Tend preserves the database model inherited from
Fern, but schema migrations can be one-way.

## Recommended migration: explicit backup and restore

1. Close any open database writers and verify Fern can still open its tasks.
2. In **Fern → Settings → About → Generate Backup**, create an exported backup
   in a directory **outside both application data directories**.
3. Keep a second copy of that export in safe storage.
4. Start Tend as a separate, fresh profile. Verify its data directory in
   **Settings → Data & Sync**; it should be the Tend path above.
5. In **Tend → Settings → About → Import Backups**, select the exported Fern
   backup. The inherited restore mechanism schedules an application restart.
6. Restart Tend, inspect a representative sample of task lists, recurring
   dates, notes, and attachments, and check that the data looks complete.
7. Make a new Tend backup before relying on the migrated profile.

If the backup format or current source schema is rejected, **stop there**.
Do not manually overwrite Tend's `tasks.db` or assume a newer database can
be downgraded safely.

## Rollback

If import goes wrong, stop using the imported Tend profile and retain the
original Fern data and backup. Tend's profile can be set aside or replaced
using a **known-good Tend backup**; do not delete the old Fern profile.

A new Tend launch and a fresh data directory are always the safer first
step. No automatic migration should be added without explicit user consent.

## Notes for developers / regression testing

A disposable fixture should cover:
- basic task lists, tags, due dates, recurrence and completion state;
- attachments and notes;
- restoring an exported backup after application restart;
- retaining the original Fern database byte-for-byte;
- handling malformed backups without destroying the active Tend profile;
- checking that updates and migrations don't silently switch data locations.

Mark this migration path as verified in the roadmap only after these cases
pass in running builds. 
