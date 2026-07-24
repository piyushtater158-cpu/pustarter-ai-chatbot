-- Add company field for hire-intent lead capture.
-- Nullable: existing rows and the older save_lead schema (pre-company) remain valid.
alter table public.leads add column if not exists company text;
