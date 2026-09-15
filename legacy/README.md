# Legacy application (Access + SQL Server)

Source files of the application being migrated to Next.js + Supabase.
Nothing in this folder is used by the build or deployed.

## Expected files

| File | Content |
|---|---|
| `*.accdb` | Access front-end (tables, relations, queries, data) |
| `export/` | Text export of Access objects: forms, reports, macros, VBA modules |
| `schema.sql` | SQL Server schema generated from SSMS (Tasks → Generate Scripts) |
| `data/*.csv` or `data.sql` | Table data |

## Notes

- GitHub rejects files over 100 MB. Compress (`.zip`) or split large files.
- Do not commit real personal data if the repo is shared.

## Contents (added after analysis)

| Path | Content |
|---|---|
| `ANALYSIS.md`, `SCHEMA_ANALYSIS.md` | Front-end and SQL Server schema analysis |
| `analysis/` | Detailed functional reports per domain, derived from the VBA code |
| `extracted/vba/` | 87 VBA modules decompressed from the .accdb (passwords redacted) |
| `extracted/forms/` | Labels, controls and row sources extracted from the 114 forms and 8 reports |
| `extracted/vba_structure.txt`, `vba_sql.txt`, `vba_msgbox.txt` | Procedure index, embedded SQL, user messages |
| `extracted/queries/` | SQL of the 414 Access queries (partial: joins lost) |
| `schema.sql`, `rowcounts.csv`, `foreign_keys.csv` | SQL Server `logiclim` DDL, volumes, foreign keys |

The full business report lives in Notion: FMC → Application existante.
