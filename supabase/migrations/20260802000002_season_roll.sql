-- Optional: schedule via pg_cron or Supabase scheduled function monthly
-- Freezes titles for the season that just ended.

create or replace function public.roll_season_if_needed()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  epoch timestamptz := '2026-01-05T00:00:00Z';
  cur int;
  prev int;
begin
  cur := greatest(1, (extract(epoch from (now() - epoch)) / 86400)::int / 28 + 1);
  prev := cur - 1;
  if prev >= 1 then
    perform public.freeze_season_titles(prev);
  end if;
end;
$$;
