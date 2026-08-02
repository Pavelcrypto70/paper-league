# Paper League online

## Option A — Local API (no Docker / no cloud)
```bash
cd tool/league_api
dart pub get
dart run bin/server.dart
```
Then in another terminal:
```bash
cd ../..
flutter run --dart-define=LEAGUE_API_URL=http://127.0.0.1:8787
```
App auto-detects the API on boot (default URL). Guest / email works against the local server. Shared ranking is real across clients on the same API.

## Option B — Supabase cloud
1. Create project, enable Anonymous auth
2. Run SQL in `supabase/migrations/` in order
3. ```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```
Supabase wins over local API when both are set.

## DEMO
If neither Supabase nor local API is reachable → DEMO bots + full desk offline.
When local API starts later, the app rescues into LIVE automatically (ping every ~12s).

## Presence
Local API exposes `POST /presence` + `GET /presence` for online peer counts. Clients heartbeat while watching the board.
