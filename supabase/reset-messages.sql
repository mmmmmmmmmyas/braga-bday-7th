-- Braga 7th: ends a testing round. Paste into Supabase → SQL Editor → Run.
-- Copies every message into messages_test_archive (with the time of the reset), then clears messages,
-- so everyone can leave a message again. No staff data in this file.
-- People already on the site keep seeing their old "sent" state until they sign in again.

create table if not exists public.messages_test_archive (
  crew_id     smallint not null,
  body        text not null,
  at          timestamptz not null,
  archived_at timestamptz not null default now()
);
alter table public.messages_test_archive enable row level security;
revoke all on public.messages_test_archive from anon, authenticated;

-- needs schema.sql to have been run (it creates public.messages); if it hasn't, this does nothing
do $$
begin
  if to_regclass('public.messages') is null then
    raise notice 'No messages table yet: run supabase/schema.sql first. Nothing was reset.';
    return;
  end if;
  insert into public.messages_test_archive (crew_id, body, at) select crew_id, body, at from public.messages;
  delete from public.messages;
end;
$$;

-- To read the archive:   select a.*, c.name from public.messages_test_archive a join public.crew c on c.id = a.crew_id order by a.archived_at, a.at;
-- To delete the archive: drop table public.messages_test_archive;
