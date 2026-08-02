-- Enable Realtime for live leaderboard
alter publication supabase_realtime add table public.season_scores;
alter publication supabase_realtime add table public.profiles;
