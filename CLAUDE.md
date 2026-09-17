# WS1

Next.js 15 App Router · TypeScript · Tailwind CSS v4 · Supabase · Deployed on Vercel.

## Stack
- **Tailwind v4**: `@import "tailwindcss"` in globals.css — no `@tailwind` directives, no `@apply` without `@reference`.
- **Supabase**: `@supabase/ssr` — `src/lib/supabase/server.ts` for server code, `src/lib/supabase/client.ts` for the browser.
- **Config-driven**: navigation and site values in `src/config/site.ts`.

## Project: ClimAccess migration
This repo hosts the rewrite of FMC's Access application "ClimAccess" (CVC maintenance management).
- **Start here**: `docs/README.md` (reading order), then `docs/CONTEXTE.md` (what the current app does), then `docs/plan/README.md` and the brief of the current step `docs/plan/etape-N.md`. Execute one step at a time.
- Code attempts live on branches `tentative-N`; the directives (`docs/`, `legacy/`, `CLAUDE.md`) live on `main`.
- Source knowledge: `legacy/SCHEMA_ANALYSIS.md`, `legacy/schema.sql`, `legacy/referentiels.txt`, `legacy/analysis/*.md` (business rules read from the VBA). Read the relevant analysis file before coding a screen.
- Out of scope for now: tablet app and web portal, see `docs/hors-perimetre-tablette-portail.md`.
- No real data in the repo, ever. Data transfer scripts run on the user's PC.

## Workflow
- Before the first commit in a session: `git config user.email noreply@anthropic.com && git config user.name Claude`
- After completing a task: commit and push directly to `main` (see README). No PR needed unless asked.
- At the end of a step: update the "État" section of its brief and tell the user what to test.

## Rules
- Server Components by default; `'use client'` only when interactivity requires it.
- Secrets are server-only: no `NEXT_PUBLIC_` prefix for API keys, never import server-only modules into client components.
- No comments unless the WHY is non-obvious. No `@apply` without `@reference`.
- Run `npm run build` before every push — fix all type errors and lint warnings.

## Deployment
- All env vars live on Vercel — never commit secrets.
- Push to `main` → production (`https://fmc-climatisation.vercel.app/`). The URL is never hard-coded: read `NEXT_PUBLIC_SITE_URL`.
- Push to any branch + open a PR → Vercel Deploy Preview.
- After pushing, tell the user the URL and what to look for.
