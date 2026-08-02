-- Paper League: profiles, seasons, scores, titles + RLS
-- Apply via: supabase db push / SQL editor

create extension if not exists "pgcrypto";

-- Profiles (1:1 with auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nickname text not null default 'trader' check (char_length(nickname) between 2 and 18),
  avatar_url text,
  hue int not null default 188,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Seasons (canonical 28d)
create table if not exists public.seasons (
  number int primary key,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  phase text not null check (phase in ('grow', 'contest', 'finals')),
  created_at timestamptz not null default now()
);

-- Live season scores
create table if not exists public.season_scores (
  season_number int not null references public.seasons (number) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  discipline numeric not null default 0,
  max_dd numeric not null default 0,
  ret_pct numeric not null default 0,
  score numeric not null default 0,
  division text not null default 'rookie'
    check (division in ('rookie', 'pro', 'elite', 'masters')),
  updated_at timestamptz not null default now(),
  primary key (season_number, user_id)
);

create index if not exists season_scores_season_score_idx
  on public.season_scores (season_number, score desc);

-- Frozen titles at season close
create table if not exists public.season_titles (
  season_number int not null references public.seasons (number) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  rank int not null check (rank >= 1),
  title_key text not null,
  created_at timestamptz not null default now(),
  primary key (season_number, user_id)
);

-- Auto profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, nickname)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nickname', 'trader')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Division from score
create or replace function public.division_for_score(s numeric)
returns text
language sql
immutable
as $$
  select case
    when s >= 92 then 'masters'
    when s >= 85 then 'elite'
    when s >= 75 then 'pro'
    else 'rookie'
  end;
$$;

-- Upsert guard: rate + absurd jump soft check (client still sends; DB stamps division)
create or replace function public.season_scores_before_write()
returns trigger
language plpgsql
as $$
declare
  prev numeric;
begin
  new.updated_at := now();
  new.division := public.division_for_score(new.score);
  if new.score < 0 or new.score > 100 then
    raise exception 'score out of bounds';
  end if;
  select score into prev
  from public.season_scores
  where season_number = new.season_number and user_id = new.user_id;
  if prev is not null and abs(new.score - prev) > 25 then
    -- clamp absurd jumps (anti-cheat lite)
    new.score := prev + sign(new.score - prev) * 25;
    new.division := public.division_for_score(new.score);
  end if;
  return new;
end;
$$;

drop trigger if exists season_scores_biu on public.season_scores;
create trigger season_scores_biu
  before insert or update on public.season_scores
  for each row execute function public.season_scores_before_write();

-- Freeze top titles for a season
create or replace function public.freeze_season_titles(p_season int)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.season_titles where season_number = p_season;
  insert into public.season_titles (season_number, user_id, rank, title_key)
  select
    p_season,
    user_id,
    row_number() over (order by score desc, updated_at asc),
    case row_number() over (order by score desc, updated_at asc)
      when 1 then 'desk_captain'
      when 2 then 'senior_risk'
      when 3 then 'tape_control'
      else 'contender'
    end
  from public.season_scores
  where season_number = p_season
  order by score desc, updated_at asc
  limit 20;
end;
$$;

-- RLS
alter table public.profiles enable row level security;
alter table public.seasons enable row level security;
alter table public.season_scores enable row level security;
alter table public.season_titles enable row level security;

drop policy if exists profiles_read on public.profiles;
create policy profiles_read on public.profiles
  for select to authenticated using (true);

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
  for insert to authenticated with check (auth.uid() = id);

drop policy if exists seasons_read on public.seasons;
create policy seasons_read on public.seasons
  for select to authenticated using (true);

drop policy if exists scores_read on public.season_scores;
create policy scores_read on public.season_scores
  for select to authenticated using (true);

drop policy if exists scores_upsert_own on public.season_scores;
create policy scores_upsert_own on public.season_scores
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists titles_read on public.season_titles;
create policy titles_read on public.season_titles
  for select to authenticated using (true);

-- Seed seasons from Paper League epoch 2026-01-05 UTC, 28 days
do $$
declare
  epoch timestamptz := '2026-01-05T00:00:00Z';
  n int;
  start_ts timestamptz;
  end_ts timestamptz;
  day_in int;
  ph text;
  now_ts timestamptz := now();
  cur int;
begin
  cur := greatest(1, (extract(epoch from (now_ts - epoch)) / 86400)::int / 28 + 1);
  for n in greatest(1, cur - 2)..(cur + 1) loop
    start_ts := epoch + ((n - 1) * 28) * interval '1 day';
    end_ts := start_ts + interval '28 days';
    day_in := greatest(1, least(28, (extract(epoch from (now_ts - start_ts)) / 86400)::int + 1));
    if day_in <= 21 then ph := 'grow';
    elsif day_in <= 26 then ph := 'contest';
    else ph := 'finals';
    end if;
    insert into public.seasons (number, starts_at, ends_at, phase)
    values (n, start_ts, end_ts, ph)
    on conflict (number) do update
      set starts_at = excluded.starts_at,
          ends_at = excluded.ends_at,
          phase = excluded.phase;
  end loop;
end $$;
