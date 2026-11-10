-- Braga 7th: sign-in schema. Safe to keep in the repo: no staff data here.
-- The staff rows live only in Supabase (seeded from supabase/setup.private.sql, which is git-ignored).

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

-- Row level security with no policies: the browser can't read or write either table directly.
alter table public.crew enable row level security;
alter table public.sign_ins enable row level security;
revoke all on public.crew, public.sign_ins from anon, authenticated;

-- Names only, for the sign-in dropdown.
create or replace function public.crew_names()
returns table (id smallint, name text)
language sql stable security definer set search_path = public
as $$
  select c.id, c.name from public.crew c order by c.name;
$$;

-- Checks a name's email on the server. Returns the card profile and records the sign-in on a match; returns no rows otherwise.
create or replace function public.sign_in(p_id smallint, p_email text)
returns table (tag text, name text, team text, title text, year smallint, photo text)
language plpgsql security definer set search_path = public
as $$
declare
  v_email text := lower(btrim(coalesce(p_email, '')));
begin
  if v_email = '' or not exists (select 1 from public.crew c where c.id = p_id and v_email = any (c.emails)) then
    return;
  end if;
  insert into public.sign_ins (crew_id, email) values (p_id, v_email);
  return query select c.tag, c.name, c.team, c.title, c.year, c.photo from public.crew c where c.id = p_id;
end;
$$;

revoke all on function public.crew_names() from public;
revoke all on function public.sign_in(smallint, text) from public;
grant execute on function public.crew_names() to anon, authenticated;
grant execute on function public.sign_in(smallint, text) to anon, authenticated;

-- Name, title and photo for every crew member, for the message stars. Same check as sign_in (the person's tag + work email), without recording a sign-in.
drop function if exists public.crew_photos(text, text);
create or replace function public.crew_profiles(p_tag text, p_email text)
returns table (tag text, name text, title text, photo text)
language plpgsql stable security definer set search_path = public
as $$
declare
  v_email text := lower(btrim(coalesce(p_email, '')));
begin
  if v_email = '' or not exists (select 1 from public.crew c where c.tag = p_tag and v_email = any (c.emails)) then
    return;
  end if;
  return query select c.tag, c.name, c.title, c.photo from public.crew c order by c.tag;
end;
$$;

revoke all on function public.crew_profiles(text, text) from public;
grant execute on function public.crew_profiles(text, text) to anon, authenticated;
