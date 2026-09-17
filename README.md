# WS1

> **Instructions for Claude:** After every change, commit and push **directly to `main`**. Do NOT create a branch, do NOT create a PR. Push straight to main so the deployment triggers immediately.

Next.js 15 App Router · TypeScript · Tailwind CSS v4 · Supabase · Deployed on Vercel.

**Live:** https://fmc-climatisation.vercel.app

## Getting started

Give this prompt to Claude Code (claude.ai/code) to start building:

> Read the README for the repo AssoConnectWorkshop/WS1 and help me build [describe your idea here].

## Stack

| | |
|---|---|
| Framework | Next.js 15 App Router — Server Components by default |
| Styling | Tailwind CSS v4 — `@import "tailwindcss"` in `globals.css`, no `@apply` without `@reference` |
| Database | Supabase (`@supabase/ssr`) — server client: `src/lib/supabase/server.ts` |
| Config | Navigation and metadata in `src/config/site.ts` |
| Deploy | Vercel — push to `main` → production |

## What's already set up

- Table **`ws1_prenoms`** in Supabase (a few test entries)
- Supabase server-side client ready to use
- Home page with a Supabase connection check
- SQL migrations run automatically at build time via `scripts/migrate.mjs`

## Adding a table

Create a file in `supabase/migrations/` with a timestamped name:

```sql
-- supabase/migrations/20260618120000_my_table.sql
create table my_table (
  id bigint generated always as identity primary key,
  name text not null
);
```

The migration will be applied automatically on the next deployment.

## Environment variables

Already configured in Vercel — never commit secrets.

| Variable | Description |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase public anon key |
| `SUPABASE_PROJECT_REF` | Project ref (used by migrations) |
| `SUPABASE_ACCESS_TOKEN` | Supabase access token (migrations) |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (server-only) — invitations et changement de rôle, étape 3 |
| `NEXT_PUBLIC_SITE_URL` | URL publique du site, utilisée pour les liens d'invitation / réinitialisation |

## Workflow

After every change: **commit and push directly to `main`**. No branches, no PRs.

## Rules

- Use `'use client'` only when the page needs interactivity (forms, hooks, events)
- Secrets are never exposed client-side
- No comments unless the "why" is non-obvious
