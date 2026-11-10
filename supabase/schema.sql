-- Braga 7th: sign-in schema. Safe to keep in the repo: no staff data here.
-- The staff rows live only in Supabase (seeded from supabase/setup.private.sql, which is git-ignored).
-- Safe to run again: it only creates what is missing and replaces the functions.

create table if not exists public.crew (
  id     smallint primary key,
  tag    text not null,                 -- crew number on the card, e.g. '001'
  name   text not null,
  team   text,
  title  text,
  emails text[] not null,               -- accepted work emails, lower-case; act as the password
  year   smallint not null,             -- year joined, shown as "EST. <year>"
  photo  text                           -- public URL of the profile picture, set later
);

create table if not exists public.sign_ins (
  id      bigint generated always as identity primary key,
  crew_id smallint not null references public.crew (id) on delete cascade,
  email   text not null,
  at      timestamptz not null default now()
);

-- One message per crew member, left in the message section (M). Once only: a second one is refused.
-- Cleared for a new round with supabase/reset-messages.sql (which archives them first).
create table if not exists public.messages (
  crew_id smallint primary key references public.crew (id) on delete cascade,
  body    text not null check (char_length(body) between 80 and 240),
  at      timestamptz not null default now()
);

-- Row level security with no policies: the browser can't read or write any table directly, only through the functions below.
alter table public.crew enable row level security;
alter table public.sign_ins enable row level security;
alter table public.messages enable row level security;
revoke all on public.crew, public.sign_ins, public.messages from anon, authenticated;

-- Names only, for the sign-in dropdown.
create or replace function public.crew_names()
returns table (id smallint, name text)
language sql stable security definer set search_path = public
as $$
  select c.id, c.name from public.crew c order by c.name;
$$;

-- Checks a name's email on the server. Returns the card profile, plus the person's own message if they have left one,
-- and records the sign-in on a match; returns no rows otherwise.
drop function if exists public.sign_in(smallint, text);
create function public.sign_in(p_id smallint, p_email text)
returns table (tag text, name text, team text, title text, year smallint, photo text, message text)
language plpgsql security definer set search_path = public
as $$
declare
  v_email text := lower(btrim(coalesce(p_email, '')));
begin
  if v_email = '' or not exists (select 1 from public.crew c where c.id = p_id and v_email = any (c.emails)) then
    return;
  end if;
  insert into public.sign_ins (crew_id, email) values (p_id, v_email);
  return query select c.tag, c.name, c.team, c.title, c.year, c.photo, m.body
    from public.crew c left join public.messages m on m.crew_id = c.id where c.id = p_id;
end;
$$;

-- Name, title, photo and message (if any) for every crew member, for the message stars.
-- Same check as sign_in (the person's tag + work email), without recording a sign-in.
drop function if exists public.crew_photos(text, text);
drop function if exists public.crew_profiles(text, text);
create function public.crew_profiles(p_tag text, p_email text)
returns table (tag text, name text, title text, photo text, message text)
language plpgsql stable security definer set search_path = public
as $$
declare
  v_email text := lower(btrim(coalesce(p_email, '')));
begin
  if v_email = '' or not exists (select 1 from public.crew c where c.tag = p_tag and v_email = any (c.emails)) then
    return;
  end if;
  return query select c.tag, c.name, c.title, c.photo, m.body
    from public.crew c left join public.messages m on m.crew_id = c.id order by c.tag;
end;
$$;

-- Saves the person's message once. Same check as sign_in; the message must be 80–240 characters after trimming.
-- Returns 'saved', 'already' (they sent one before), 'invalid' (wrong length) or 'denied' (email doesn't match).
create or replace function public.submit_message(p_tag text, p_email text, p_body text)
returns text
language plpgsql security definer set search_path = public
as $$
declare
  v_email text := lower(btrim(coalesce(p_email, '')));
  v_body  text := regexp_replace(coalesce(p_body, ''), '^\s+|\s+$', '', 'g');
  v_id    smallint;
begin
  select c.id into v_id from public.crew c where c.tag = p_tag and v_email <> '' and v_email = any (c.emails);
  if v_id is null then return 'denied'; end if;
  if char_length(v_body) < 80 or char_length(v_body) > 240 then return 'invalid'; end if;
  insert into public.messages (crew_id, body) values (v_id, v_body) on conflict (crew_id) do nothing;
  if found then return 'saved'; end if;
  return 'already';
end;
$$;

revoke all on function public.crew_names() from public;
revoke all on function public.sign_in(smallint, text) from public;
revoke all on function public.crew_profiles(text, text) from public;
revoke all on function public.submit_message(text, text, text) from public;
grant execute on function public.crew_names() to anon, authenticated;
grant execute on function public.sign_in(smallint, text) to anon, authenticated;
grant execute on function public.crew_profiles(text, text) to anon, authenticated;
grant execute on function public.submit_message(text, text, text) to anon, authenticated;
