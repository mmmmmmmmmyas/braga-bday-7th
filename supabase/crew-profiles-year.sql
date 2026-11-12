-- Adds each crew member's EST year to crew_profiles, so the final section can show their tenure badge on hover.
-- Run once in the Supabase SQL Editor. Safe to re-run. No data changes: it only replaces the function and re-grants it.
drop function if exists public.crew_profiles(text, text);
create function public.crew_profiles(p_tag text, p_email text)
returns table (tag text, name text, title text, year smallint, photo text, message text)
language plpgsql stable security definer set search_path = public
as $$
declare
  v_email text := lower(btrim(coalesce(p_email, '')));
begin
  if v_email = '' or not exists (select 1 from public.crew c where c.tag = p_tag and v_email = any (c.emails)) then
    return;
  end if;
  return query select c.tag, c.name, c.title, c.year, c.photo, m.body
    from public.crew c left join public.messages m on m.crew_id = c.id order by c.tag;
end;
$$;

revoke all on function public.crew_profiles(text, text) from public;
grant execute on function public.crew_profiles(text, text) to anon, authenticated;
