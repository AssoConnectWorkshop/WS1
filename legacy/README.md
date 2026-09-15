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
