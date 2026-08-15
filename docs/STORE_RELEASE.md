# Store release checklist — Paper League

Package: `com.paperleague.paper_league`  
Version: `1.0.1+2`  
Role: free traffic asset → Desk Club (`https://t.me/Desk_Club`)  
No IAP.

## 1. One-time local setup (owner)

```powershell
# Upload keystore (creates android/keystore + android/key.properties — gitignored)
# Same pattern as Trade Master tools/create_upload_keystore.ps1
# Example:
#   keytool -genkeypair -v -keystore android/keystore/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
# Then android/key.properties:
#   storePassword=...
#   keyPassword=...
#   keyAlias=upload
#   storeFile=keystore/upload-keystore.jks

flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Back up the `.jks` and passwords offline. Losing them blocks Play updates for this upload key.

Without `android/key.properties`, release is **debug-signed** — do not upload.

## 2. Android AAB

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

CI: `.github/workflows/build-play-aab.yml` (needs secrets `ANDROID_KEYSTORE_BASE64` + `ANDROID_KEY_PROPERTIES`).

## 3. Legal URLs (after Pages deploy)

- Privacy: `https://pavelcrypto70.github.io/paper-league/privacy.html`
- Terms: `https://pavelcrypto70.github.io/paper-league/terms.html`

## 4. Listing copy

**Category:** Education / Finance (educational simulation)  
**Content rating:** everyone / skip graphic violence; declare educational finance.

### Short (EN, ≤80)

Paper trading desk ranked by discipline — not luck.

### Full (EN)

Paper League is a free practice desk for traders.

You take simulated trades with mandatory stops and risk %. Seasons last 28 days. Rank comes from discipline — not lottery PnL.

What you get
• Paper desk with live candles
• Playbooks, tape drill, daily streak
• League standing (practice, not a broker)
• EN community: Desk Club

Education / simulation only. Not financial advice. No real money.

Languages: English, Español, Português, Русский — choose on the first screen.

Join Desk Club: https://t.me/Desk_Club

### ES short

Versión educativa. No es asesoramiento financiero.

### PT short

Versão educacional. Não é aconselhamento financeiro.

### RU short

Образовательное приложение. Не финансовый совет.

## 5. Pre-submit QA

- [ ] Language gate first (EN/ES/PT/RU)
- [ ] Legal / disclaimer accept before app
- [ ] Privacy + Terms open from Profile
- [ ] Join Desk Club opens https://t.me/Desk_Club
- [ ] Adaptive icon + splash
- [ ] Release AAB is NOT debug-signed
- [ ] Crash-free smoke on 1–2 devices

## 6. Store pack (ready to paste)

| Asset | Path |
|---|---|
| Play listing EN/ES/PT/RU | `store/PLAY_STORE_LISTING.md` |
| RuStore listing | `store/RUSTORE_LISTING.md` |
| Data safety answers | `store/DATA_SAFETY.md` |
| Copy-paste for consoles | `store/CONSOLE_PASTE.txt` |
| Screenshot order | `store/SCREENSHOTS.md` |
| Phone 1080×1920 (5) | `store/screenshots/` |
| Feature graphic 1024×500 | `store/feature-graphic.png` |
| High-res icon 512×512 | `store/icon-512.png` |

Icons/splash (Android only — `ios: false` in pubspec):

```
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
