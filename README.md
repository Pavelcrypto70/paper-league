# Paper League

Paper trading desk ranked by **discipline**, not luck. Competitive season desk with LIVE league, daily streak economy, and process scoring.

## What you get

- Desk / Book / League / Profile — OLED ink terminal
- Candles with Binance REST history + live WS trades (Android/desktop); synthetic fallback elsewhere
- Mandatory stops, risk-% sizing, playbooks, Tape Drill, Daily Desk
- **28-day seasons** with divisions, ceremony, titles
- **LIVE league** via local API (or Supabase dart-defines) — DEMO bots only when offline
- Soft currency **Credits** + desk upgrades (no IAP)
- Local analytics + crash ring (export from Profile)

## Run the desk

```bash
flutter pub get
flutter run -d windows
# or android / chrome
```

## Always-on LIVE (recommended)

```bash
cd tool/league_api
dart pub get
dart run bin/server.dart
```

Then launch the app — it auto-detects `http://127.0.0.1:8787`. Guest or email signs into a **shared** board. Open a second client to densify presence.

Supabase (optional): see [docs/SUPABASE.md](docs/SUPABASE.md).

## DEMO mode

If League API and Supabase are unreachable → DEMO badge + on-device rivals. Desk trading still works fully offline. When the API comes up, the app can rescue into LIVE.

## Visual system

Ink / cyan OLED desk — Space Grotesk + IBM Plex Sans + tabular figures.  
Educational simulation only. No real money.
