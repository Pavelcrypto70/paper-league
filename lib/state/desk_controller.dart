import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:paper_league/config/app_links.dart';
import 'package:paper_league/data/league_repository.dart';
import 'package:paper_league/data/market_feed.dart';
import 'package:paper_league/domain/achievements.dart';
import 'package:paper_league/domain/bounce_scenario.dart';
import 'package:paper_league/domain/daily_desk.dart';
import 'package:paper_league/domain/desk_meta.dart';
import 'package:paper_league/domain/league_live.dart';
import 'package:paper_league/domain/league_remote.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/domain/playbook.dart';
import 'package:paper_league/domain/season.dart';
import 'package:paper_league/domain/season_liveops.dart';
import 'package:paper_league/services/analytics.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeskController extends ChangeNotifier {
  DeskController({MarketFeed? feed}) : _feed = feed ?? MarketFeed();

  final MarketFeed _feed;
  final _rng = Random();

  static const startingCash = 10000.0;
  static const riskDefault = 0.02;

  final Map<String, List<Candle>> books = {};
  String activeSymbol = MarketFeed.symbols.first.id;
  Position? position;
  final List<ClosedTrade> history = [];
  final List<double> equityCurve = [startingCash];
  ClosedTrade? lastRecap;
  /// Freshly unlocked achievement keys — consumed by UI toast.
  List<String> pendingAchievements = [];
  final Set<String> unlockedAchievements = {};

  double cash = startingCash;
  double peakEquity = startingCash;
  double maxDrawdown = 0;
  int discipline = 0;
  bool loading = true;
  String? error;
  bool usedLiveFeed = false;
  DateTime weekEndsAt = DateTime.now().toUtc(); // kept for compat → season end
  int tapeDrillPoints = 0;
  List<Playbook> playbooks = Playbook.defaultPack();
  /// Levels pushed onto the desk chart from a playbook.
  PlaybookLevels? activePlaybookLevels;
  int playbookSeedToken = 0;
  int seasonBestRank = 99;
  String? seasonTitleKey;
  final LeaguePulse leaguePulse = LeaguePulse();
  DailyDeskState daily = DailyDeskState.empty(DateTime.now().toUtc());
  final Set<String> seasonRewardIds = {};
  /// After a strong recap — UI should offer share ritual.
  ClosedTrade? pendingShareRitual;
  bool tapeDrillIntroSeen = false;
  bool playbooksIntroSeen = false;
  int _leaguePulseEvery = 0;
  Timer? _leagueTimer;
  List<LeagueEntry> _publishedBoard = [];
  LeagueRepository? _leagueRepo;
  StreamSubscription? _remoteBoardSub;
  List<RemoteScoreRow> _remoteRows = const [];
  List<SeasonTitleRow> remoteTitles = const [];
  bool leagueIsLive = false;
  int? lastCeremonySeason;
  bool firstRunHintDone = false;
  bool firstStopTradeDone = false;
  bool firstGestureDone = false;
  bool tutorialTrade = false;
  bool tutorialStopSet = false;
  /// Beginner path: 0=idle, 1=candle, 2=trade, 3=stop, 4=journal, 5=done.
  int beginnerPathStep = 0;
  /// Floor 0 orientation: 0=chart, 1=btc, 2=candle highlight, 3=done.
  int orientStep = 0;
  bool communityGateShown = false;
  bool communityGateAccepted = false;
  bool communityGateDismissed = false;
  bool firstWinCeremonySeen = false;
  bool softAuthPromptSeen = false;
  /// Risk fraction chosen in mission 3 (0.005 / 0.01 / 0.02).
  double tutorialRiskPct = 0.01;
  /// Closed tutorial trade awaiting the mission 4 journal (memory only).
  ClosedTrade? lastTutorialTrade;
  /// Daily Desk reminder hour picked after the first win (null = off).
  int? reminderHour;
  /// Phase 2: bridge after beginner path ("what to do next").
  bool phase2BridgeSeen = false;
  /// Phase 3: week-done bridge that explains League + tabs before free terminal.
  bool phase3BridgeSeen = false;
  /// Phase 3 coach step inside the bridge (0..n).
  int phase3Step = 0;
  /// Shell should switch to this bottom-tab index once (0 desk / 1 book / 2 league / 3 you).
  int? pendingShellTab;
  /// League screen explainer dismissed.
  bool leagueIntroSeen = false;
  /// Glossary of terms after 3 move copies.
  bool glossarySeen = false;
  /// First free-terminal coach (League week, desks 8–14).
  bool phase4BridgeSeen = false;
  /// Short + Tape Drill bridge (desks 15–21).
  bool phase5BridgeSeen = false;
  /// Season Contest/Finals bridge (desks 22–28).
  bool phase6BridgeSeen = false;
  /// Short teach lesson completed once.
  bool shortTeachDone = false;
  /// Teaching chart is a Short fade (not Long bounce).
  bool teachIsShort = false;
  /// Phase 2: user watched move-1 replay at least once.
  bool move1ReplaySeen = false;
  /// Phase 2: successful paper copies of move 1.
  int move1Copies = 0;
  /// Phase 2: guided copy trade open (like tutorial, separate from missions).
  bool moveCopyTrade = false;
  /// Teaching candles for move copy (distinct bounce chart per day).
  List<Candle>? moveTeachCandles;
  double? moveTeachBuy;
  int moveTeachScenarioId = 0;
  int _teachTick = 0;
  /// Phase 2: user is inside a Daily Desk session from Today hub (ephemeral).
  bool todaySessionActive = false;
  /// Phase 2: desks completed while in habit mode.
  int habitDesksDone = 0;
  /// Phase 2: which habit-day plan the Today hub is showing (1–28).
  int habitViewDay = 1;
  /// UI one-shot: shell should present first-win / community ceremonies.
  bool pendingFirstWinCeremony = false;
  bool pendingCommunityGate = false;
  DeskMeta meta = DeskMeta();
  SeasonProgress seasonProgress = SeasonProgress();
  /// One-shot juice cue for UI (fill / stop / tp / win / loss).
  String? pendingJuice;
  bool wsTapeLive = false;

  String nickname = 'trader';
  String? avatarPath;
  int avatarHue = 188;

  double previousMark = 0;
  int markDir = 0;
  String timeframe = '15m';
  bool coachDone = false;

  /// Pre-trade mandatory until 10 closes or discipline ≥ 80.
  bool get preTradeRequired => history.length < 10 && discipline < 80;

  bool get needsFirstRunTrade => !firstStopTradeDone;

  bool get tabsUnlocked => firstGestureDone;

  bool get beginnerPathActive => beginnerPathStep < 5;

  bool get orientDone => orientStep >= 3;

  /// Show chart/BTC/candle orientation before the mission rail.
  bool get showOrientation => beginnerPathActive && !orientDone;

  int get beginnerMissionsDone => beginnerPathStep.clamp(0, 5) >= 5
      ? 4
      : (beginnerPathStep - 1).clamp(0, 4);

  /// Recent swing low — the “buy line” we highlight on move-1 copy.
  double? get move1BounceLine {
    final c = candles;
    if (c.length < 8) return null;
    final from = max(0, c.length - 28);
    var low = c[from].low;
    for (var i = from; i < c.length; i++) {
      if (c[i].low < low) low = c[i].low;
    }
    return low;
  }

  bool get move1CopyDone => move1Copies >= 1;

  /// Path day number shown in the Today header (1–28).
  int get habitPathDay => habitViewDay.clamp(1, 28);

  /// Day N is complete only after that Daily Desk is closed.
  /// First move-copy from the bridge does NOT close day 1 — that is the lesson;
  /// Daily Desk is the practice that counts the day.
  bool get habitViewDayDone => habitDesksDone >= habitViewDay;

  bool get canAdvanceHabitDay => habitViewDayDone && habitViewDay < 28;

  /// Linear phase-2 step for “what now” coaching.
  /// 0 = need move replay/copy, 1 = need today’s desk, 2 = day done → next, 3 = rooted.
  int get phase2Focus {
    if (!move1CopyDone) return 0;
    if (!habitViewDayDone) return 1;
    if (canAdvanceHabitDay) return 2;
    return 3;
  }

  /// Book opens after the first successful move copy.
  bool get bookTabUnlocked => firstGestureDone && move1CopyDone;

  /// Seven Daily Desks (or 7-day streak) — habit roots planted.
  /// Habit week = 7 counted Daily Desks. Login streak is XP only — never a phase skip.
  bool get habitWeekDone => firstGestureDone && move1CopyDone && habitDesksDone >= 7;

  /// Desk Club invite gate (Telegram) — same rule as `_queueCommunityGateIfNeeded`.
  bool get deskClubReady => move1Copies >= 2 && meta.loginStreak >= 3;

  /// League waits until a week of discipline (or 7 habit desks).
  bool get leagueTabUnlocked => habitWeekDone;

  /// Free terminal only after Phase 3 bridge explains League + tabs.
  /// Day 3 unlocks Desk Club tease inside Today hub, NOT the raw cockpit.
  bool get fullTerminalUnlocked => habitWeekDone && phase3BridgeSeen;

  /// Desk tab shows the Today hub instead of the raw terminal.
  bool get showTodayHub =>
      firstGestureDone && !beginnerPathActive && !habitWeekDone && !todaySessionActive;

  bool get showPhase2Bridge => firstGestureDone && !beginnerPathActive && !phase2BridgeSeen;

  /// Week closed — walk the user into League before dumping them on the terminal.
  bool get showPhase3Bridge => habitWeekDone && !phase3BridgeSeen;

  /// Terms card after 3 copies (Book still locked until move1; this is the tour).
  bool get showGlossaryTour => move1Copies >= 3 && !glossarySeen;

  /// After P3 — one screen: how to spend desks 8–14.
  bool get showPhase4Bridge => fullTerminalUnlocked && !phase4BridgeSeen && habitDesksDone < 14;

  /// At desk 14+ — Short lesson + Tape Drill before blind Short spam.
  bool get showPhase5Bridge => fullTerminalUnlocked && habitDesksDone >= 14 && !phase5BridgeSeen;

  /// At desk 21+ — season Contest / Finals stakes.
  bool get showPhase6Bridge => fullTerminalUnlocked && habitDesksDone >= 21 && !phase6BridgeSeen;

  /// Journey stage for the roadmap card:
  /// 0 orientation+missions, 1 move 1, 2 habit week, 3 league week, 4 short+drill, 5 season.
  int get journeyStage {
    if (beginnerPathActive) return 0;
    if (!move1CopyDone) return 1;
    if (!habitWeekDone) return 2;
    if (habitDesksDone < 14) return 3;
    if (habitDesksDone < 21) return 4;
    return 5;
  }

  /// Unified “what to tap next” for free terminal + late phases.
  /// 0 daily incomplete, 1 check league, 2 short teach, 3 tape drill, 4 season grind, 5 done today.
  int get nextStepKind {
    if (!fullTerminalUnlocked) return 0;
    if (!daily.complete) return 0;
    if (habitDesksDone >= 14 && !shortTeachDone) return 2;
    if (habitDesksDone >= 14 && habitDesksDone < 21 && tapeDrillPoints < 5) return 3;
    if (habitDesksDone >= 21) return 4;
    if (!leagueIntroSeen) return 1;
    return 5;
  }

  bool get hasScoredProcess => history.isNotEmpty && !tutorialTrade;

  String get processDisplay => hasScoredProcess ? '$discipline' : '—';

  String get rankDisplay => firstGestureDone && history.isNotEmpty ? '$yourRank' : '—';

  int _tradesLast10Min = 0;
  DateTime? _lastLossAt;
  bool _widenedStop = false;
  Timer? _tick;
  SharedPreferences? _prefs;
  /// After TF/bootstrap rebuild — skip stop/TP until a live tick updates the pin.
  bool _deferStops = false;
  double? _restoredMark;

  List<Candle> get candles => books[activeSymbol] ?? const [];
  double get mark {
    if (moveCopyTrade && moveTeachCandles != null && moveTeachCandles!.isNotEmpty) {
      return moveTeachCandles!.last.close;
    }
    return candles.isEmpty ? 0 : candles.last.close;
  }

  /// Mark for any symbol book (positions must not use active chart mark).
  double markFor(String symbol) => _markFor(symbol);

  MarketSymbol get activeMeta => MarketFeed.symbols.firstWhere(
        (s) => s.id == activeSymbol,
        orElse: () => MarketFeed.symbols.first,
      );

  double get equity {
    final pos = position;
    if (pos == null) return cash;
    // Cash holds entry notional as collateral while the position is open.
    final m = _markFor(pos.symbol);
    return cash + pos.qty * pos.entry + pos.unrealized(m);
  }

  double _markFor(String symbol) {
    if (moveCopyTrade && moveTeachCandles != null && moveTeachCandles!.isNotEmpty) {
      return moveTeachCandles!.last.close;
    }
    final c = books[symbol];
    if (c == null || c.isEmpty) return 0;
    return c.last.close;
  }

  double get dayPnl => equity - startingCash;
  double get dayPnlPct => dayPnl / startingCash * 100;
  double get returnFromStartPct => dayPnlPct;

  int get tradesCount => history.length;
  int get winsCount => history.where((t) => t.pnl > 0).length;
  int get lossesCount => history.where((t) => t.pnl < 0).length;

  double get winRatePct => history.isEmpty ? 0 : winsCount / history.length * 100;
  double get lossRatePct => history.isEmpty ? 0 : lossesCount / history.length * 100;

  double get avgR {
    if (history.isEmpty) return 0;
    return history.map((t) => t.rMultiple).reduce((a, b) => a + b) / history.length;
  }

  double get atrPct {
    final c = candles;
    if (c.length < 20) return 1.5;
    final slice = c.sublist(c.length - 20);
    var sum = 0.0;
    for (final x in slice) {
      sum += (x.high - x.low) / x.close;
    }
    return sum / slice.length * 100;
  }

  String get volLabel {
    final a = atrPct;
    if (a >= 2.2) return 'HIGH';
    if (a >= 1.2) return 'MED';
    return 'LOW';
  }

  int get _barsPerDay => MarketFeed.barsPerDay(timeframe);

  double change24hPct(String symbol) {
    final c = books[symbol];
    if (c == null || c.length < 2) return 0;
    final last = c.last.close;
    final lookback = _barsPerDay;
    final prev = c[max(0, c.length - lookback)].close;
    if (prev <= 0) return 0;
    return (last - prev) / prev * 100;
  }

  /// Daily range volatility % (high-low)/close over ~24h window.
  double dayVolPct(String symbol) {
    final c = books[symbol];
    if (c == null || c.length < 8) return 0;
    final n = _barsPerDay;
    final slice = c.length > n ? c.sublist(c.length - n) : c;
    var hi = slice.first.high;
    var lo = slice.first.low;
    for (final x in slice) {
      if (x.high > hi) hi = x.high;
      if (x.low < lo) lo = x.low;
    }
    final last = slice.last.close;
    if (last <= 0) return 0;
    return (hi - lo) / last * 100;
  }

  List<MarketSymbol> get symbolsByVolatility {
    final list = [...MarketFeed.symbols];
    list.sort((a, b) => dayVolPct(b.id).compareTo(dayVolPct(a.id)));
    return list;
  }

  double get leagueScore {
    final disc = discipline.toDouble();
    final riskCtrl = (100 - maxDrawdown * 8).clamp(20.0, 100.0);
    final ret = (50 + dayPnlPct * 4).clamp(20.0, 100.0);
    return disc * 0.6 + riskCtrl * 0.25 + ret * 0.15;
  }

  double get discPart => discipline * 0.6;
  double get ddPart => (100 - maxDrawdown * 8).clamp(20.0, 100.0) * 0.25;
  double get retPart => (50 + dayPnlPct * 4).clamp(20.0, 100.0) * 0.15;

  SeasonInfo get season => SeasonClock.of(DateTime.now());

  List<LeagueFeedItem> get leagueFeed => leaguePulse.feed;

  List<SeasonMemory> get seasonMemories =>
      leaguePulse.memories(season, seasonBestRank);

  List<SeasonReward> get seasonRewards => buildSeasonRewards(
        bestRank: seasonBestRank,
        tapePts: tapeDrillPoints,
        seasonDay: season.day,
        extra: seasonRewardIds,
      );

  List<LeagueEntry> get leaderboard {
    if (_publishedBoard.isEmpty) {
      _publishLeagueBoard();
    }
    return _publishedBoard;
  }

  LeagueDivision get yourDivision => divisionForScore(leagueScore);

  void _publishLeagueBoard() {
    final raw = _rawBoard();
    _publishedBoard = leaguePulse.withDeltas(raw);
    leaguePulse.commitSnapshot(raw);
  }

  List<LeagueEntry> _rawBoard() {
    final you = LeagueEntry(
      name: nickname,
      score: leagueScore,
      discipline: discipline.toDouble(),
      maxDd: maxDrawdown,
      retPct: dayPnlPct,
      isYou: true,
      hue: avatarHue,
      streak: _seasonStreak(),
      discPart: discPart,
      ddPart: ddPart,
      retPart: retPart,
      division: yourDivision,
      remote: leagueIsLive,
    );

    if (leagueIsLive && _remoteRows.isNotEmpty) {
      final others = _remoteRows.where((r) => !r.isYou).map((r) {
        return LeagueEntry(
          name: r.nickname,
          score: r.score,
          discipline: r.discipline,
          maxDd: r.maxDd,
          retPct: r.retPct,
          hue: r.hue,
          discPart: r.discipline * 0.6,
          ddPart: (100 - r.maxDd * 8).clamp(20.0, 100.0) * 0.25,
          retPart: (50 + r.retPct * 4).clamp(20.0, 100.0) * 0.15,
          division: r.division,
          remote: true,
          userId: r.userId,
        );
      });
      // Hybrid fill if thin field — fewer ghosts when real peers exist.
      final merged = [...others, you];
      final realCount = others.length + 1;
      final target = realCount >= 4 ? realCount.clamp(4, 12) : 6;
      if (merged.length < target) {
        final need = target - merged.length;
        final ghosts = leaguePulse.baseRivals(season).take(need);
        merged.addAll(ghosts.map((g) => g.copyWith(remote: false)));
      }
      return merged..sort((a, b) => b.score.compareTo(a.score));
    }

    final bots = leaguePulse.baseRivals(SeasonClock.of(DateTime.now()));
    return [...bots, you]..sort((a, b) => b.score.compareTo(a.score));
  }

  Future<void> bindOnline(LeagueRepository repo, {required bool live}) async {
    _leagueRepo = repo;
    leagueIsLive = live && repo.isLive;
    _remoteBoardSub?.cancel();
    if (!leagueIsLive) {
      _publishLeagueBoard();
      notifyListeners();
      return;
    }
    await repo.ensureSeasonSeeded();
    await repo.startWatching(season.number);
    _remoteRows = repo.latestBoard;
    remoteTitles = await repo.fetchTitles();
    _remoteBoardSub = repo.boardStream.listen((rows) {
      _remoteRows = rows;
      _publishLeagueBoard();
      notifyListeners();
    });
    await syncLeagueScore(force: true);
    _publishLeagueBoard();
    notifyListeners();
  }

  Future<void> syncLeagueScore({bool force = false}) async {
    final repo = _leagueRepo;
    if (repo == null || !leagueIsLive) return;
    // Nickname required before league publish.
    final nick = nickname.trim();
    if (nick.length < 2 || nick.toLowerCase() == 'trader') {
      return;
    }
    await repo.upsertProfile(nickname: nick, hue: avatarHue);
    await repo.upsertMyScore(
      ScoreUpsert(
        seasonNumber: season.number,
        discipline: discipline.toDouble(),
        maxDd: maxDrawdown,
        retPct: dayPnlPct,
        score: leagueScore,
      ),
      force: force,
    );
    Analytics.log('score_sync', {'score': leagueScore, 'season': season.number});
  }

  bool get needsLeagueNickname {
    final nick = nickname.trim();
    return leagueIsLive && (nick.length < 2 || nick.toLowerCase() == 'trader');
  }

  Future<void> markCeremonySeen(int n) async {
    lastCeremonySeason = n;
    await _prefs?.setInt('ceremonySeason', n);
  }

  Future<void> completeFirstRunHint() async {
    firstRunHintDone = true;
    await _prefs?.setBool('firstRunHint', true);
    notifyListeners();
  }

  int get yourRank {
    final i = leaderboard.indexWhere((e) => e.isYou);
    return i < 0 ? 0 : i + 1;
  }

  int get yourRankDelta {
    final you = leaderboard.where((e) => e.isYou);
    if (you.isEmpty) return 0;
    return you.first.rankDelta;
  }

  int _seasonStreak() {
    if (history.isEmpty) return 0;
    var n = 0;
    for (final t in history) {
      if (t.pnl >= 0) {
        n++;
      } else {
        break;
      }
    }
    return n;
  }

  static const _freshStamp = 'paper_league_fresh_20261005_fullpath';

  static const _freshWipeKeys = [
    'orientStep',
    'phase2BridgeSeen',
    'phase3BridgeSeen',
    'phase3Step',
    'leagueIntroSeen',
    'glossarySeen',
    'phase4BridgeSeen',
    'phase5BridgeSeen',
    'phase6BridgeSeen',
    'shortTeachDone',
    'move1ReplaySeen',
    'move1Copies',
    'habitDesksDone',
    'habitViewDay',
    'moveCopyTrade',
    'tutorialRiskPct',
    'reminderHour',
    'firstGesture',
    'firstRunHint',
    'firstStopTrade',
    'tutorialTrade',
    'tutorialStopSet',
    'beginnerPathStep',
    'communityGateShown',
    'communityGateAccepted',
    'communityGateDismissed',
    'firstWinCeremonySeen',
    'softAuthPromptSeen',
    'coachDone',
    'historyJson',
    'openPos',
    'cash',
    'equityCurve',
    'discipline',
    'peakEquity',
    'maxDrawdown',
    'dailyJson',
    'achievements',
    'deskMeta',
    'seasonProgress',
    'seasonRewards',
    'tapeDrillPts',
    'tapeDrillIntro',
    'playbooksIntro',
    'ceremonySeason',
    'playbooksJson',
    'nickname',
    'avatarPath',
    'avatarHue',
    'authGateSkipped',
    'local_league_token',
    'local_league_uid',
    'league_upsert_queue',
    'qaPresetApplied',
  ];

  static Future<void> wipeLocalProgressIfNeeded() async {
    final p = await SharedPreferences.getInstance();
    if (p.getBool(_freshStamp) ?? false) return;
    for (final key in _freshWipeKeys) {
      await p.remove(key);
    }
    await p.setBool(_freshStamp, true);
  }

  /// QA shortcut via URL (`?qa=fresh|day3|week|terminal`) so testers can reach late phases.
  static Future<void> applyQaPreset(String? preset) async {
    if (preset == null || preset.isEmpty) return;
    final p = await SharedPreferences.getInstance();

    // Always skip language + legal when any QA preset is in the URL — even if
    // progress was already applied (old sessions may have qaPresetApplied
    // without lang_chosen, which otherwise early-returns onto the language gate).
    await p.setString('lang', 'ru');
    await p.setBool('lang_chosen_v1', true);
    await p.setBool('disclaimer_accepted_v1', true);

    final done = p.getString('qaPresetApplied');
    if (done == preset && _qaPresetLooksApplied(p, preset)) return;
    for (final key in _freshWipeKeys) {
      await p.remove(key);
    }
    // Re-apply gate skip after wipe (wipe removes nothing for these keys, but be explicit).
    await p.setString('lang', 'ru');
    await p.setBool('lang_chosen_v1', true);
    await p.setBool('disclaimer_accepted_v1', true);

    if (preset != 'fresh') {
      final desks = switch (preset) {
        'day3' => 2,
        'week' || 'terminal' => 7,
        'league' => 10,
        'short' => 15,
        'season' => 22,
        _ => 0,
      };
      // day3: 2 copies + streak 3 so Desk Club invite is actually testable.
      final copies = switch (preset) {
        'day3' => 2,
        'week' || 'terminal' || 'league' || 'short' || 'season' => 3,
        _ => 1,
      };
      await p.setBool('firstGesture', true);
      await p.setInt('beginnerPathStep', 5);
      await p.setInt('orientStep', 3);
      await p.setBool('phase2BridgeSeen', true);
      await p.setBool('move1ReplaySeen', true);
      await p.setInt('move1Copies', copies);
      await p.setInt('habitDesksDone', desks);
      await p.setInt('habitViewDay', (desks + 1).clamp(1, 28));
      if (preset == 'day3') {
        await p.setString(
          'deskMeta',
          jsonEncode(DeskMeta(loginStreak: 3, lastLoginDay: DailyDeskState.keyFor(DateTime.now().toUtc())).toJson()),
        );
      }
      if (preset == 'terminal' || preset == 'league' || preset == 'short' || preset == 'season') {
        await p.setBool('phase3BridgeSeen', true);
        await p.setInt('phase3Step', 4);
        await p.setBool('glossarySeen', true);
      }
      if (preset == 'terminal') {
        await p.setBool('leagueIntroSeen', false);
      }
      if (preset == 'league') {
        await p.setBool('phase4BridgeSeen', false);
        await p.setBool('leagueIntroSeen', false);
      }
      if (preset == 'short') {
        await p.setBool('phase4BridgeSeen', true);
        await p.setBool('phase5BridgeSeen', false);
        await p.setBool('shortTeachDone', false);
        await p.setBool('leagueIntroSeen', true);
      }
      if (preset == 'season') {
        await p.setBool('phase4BridgeSeen', true);
        await p.setBool('phase5BridgeSeen', true);
        await p.setBool('shortTeachDone', true);
        await p.setBool('phase6BridgeSeen', false);
        await p.setBool('leagueIntroSeen', true);
      }
    }
    await p.setString('qaPresetApplied', preset);
  }

  static bool _qaPresetLooksApplied(SharedPreferences p, String preset) {
    final desks = p.getInt('habitDesksDone') ?? 0;
    final first = p.getBool('firstGesture') ?? false;
    return switch (preset) {
      'fresh' => !first && desks == 0,
      'day3' => first && desks >= 2,
      'week' => first && desks >= 7 && !(p.getBool('phase3BridgeSeen') ?? false),
      'terminal' => first && desks >= 7 && (p.getBool('phase3BridgeSeen') ?? false),
      'league' => first && desks >= 10 && (p.getBool('phase3BridgeSeen') ?? false),
      'short' => first && desks >= 15,
      'season' => first && desks >= 22,
      _ => false,
    };
  }

  Future<void> _maybeFreshStart() async {
    await wipeLocalProgressIfNeeded();
  }

  Future<void> bootstrap() async {
    loading = true;
    notifyListeners();
    _prefs = await SharedPreferences.getInstance();
    await _maybeFreshStart();
    nickname = _prefs?.getString('nickname') ?? 'trader';
    avatarPath = _prefs?.getString('avatarPath');
    avatarHue = _prefs?.getInt('avatarHue') ?? 188;
    discipline = _prefs?.getInt('discipline') ?? 0;
    coachDone = _prefs?.getBool('coachDone') ?? false;
    tapeDrillPoints = _prefs?.getInt('tapeDrillPts') ?? 0;
    seasonBestRank = _prefs?.getInt('seasonBestRank') ?? 99;
    playbooks = Playbook.decodeList(_prefs?.getString('playbooksJson'));
    tapeDrillIntroSeen = _prefs?.getBool('tapeDrillIntro') ?? false;
    playbooksIntroSeen = _prefs?.getBool('playbooksIntro') ?? false;
    lastCeremonySeason = _prefs?.getInt('ceremonySeason');
    firstRunHintDone = _prefs?.getBool('firstRunHint') ?? false;
    firstStopTradeDone = _prefs?.getBool('firstStopTrade') ?? false;
    tutorialTrade = _prefs?.getBool('tutorialTrade') ?? false;
    tutorialStopSet = _prefs?.getBool('tutorialStopSet') ?? false;
    firstGestureDone = _prefs?.getBool('firstGesture') ?? false;
    communityGateShown = _prefs?.getBool('communityGateShown') ?? false;
    communityGateAccepted = _prefs?.getBool('communityGateAccepted') ?? false;
    communityGateDismissed = _prefs?.getBool('communityGateDismissed') ?? false;
    firstWinCeremonySeen = _prefs?.getBool('firstWinCeremonySeen') ?? false;
    softAuthPromptSeen = _prefs?.getBool('softAuthPromptSeen') ?? false;
    tutorialRiskPct = _prefs?.getDouble('tutorialRiskPct') ?? 0.01;
    reminderHour = _prefs?.getInt('reminderHour');
    orientStep = (_prefs?.getInt('orientStep') ?? 0).clamp(0, 3);
    phase2BridgeSeen = _prefs?.getBool('phase2BridgeSeen') ?? false;
    phase3BridgeSeen = _prefs?.getBool('phase3BridgeSeen') ?? false;
    phase3Step = (_prefs?.getInt('phase3Step') ?? 0).clamp(0, 4);
    leagueIntroSeen = _prefs?.getBool('leagueIntroSeen') ?? false;
    glossarySeen = _prefs?.getBool('glossarySeen') ?? false;
    phase4BridgeSeen = _prefs?.getBool('phase4BridgeSeen') ?? false;
    phase5BridgeSeen = _prefs?.getBool('phase5BridgeSeen') ?? false;
    phase6BridgeSeen = _prefs?.getBool('phase6BridgeSeen') ?? false;
    shortTeachDone = _prefs?.getBool('shortTeachDone') ?? false;
    move1ReplaySeen = _prefs?.getBool('move1ReplaySeen') ?? false;
    move1Copies = _prefs?.getInt('move1Copies') ?? 0;
    habitDesksDone = _prefs?.getInt('habitDesksDone') ?? 0;
    final storedView = _prefs?.getInt('habitViewDay');
    if (storedView != null) {
      habitViewDay = storedView.clamp(1, 28);
    } else {
      // First incomplete day. After a desk closes we persist view on that day for the CTA.
      habitViewDay = (habitDesksDone + 1).clamp(1, 28);
    }
    moveCopyTrade = _prefs?.getBool('moveCopyTrade') ?? false;
    final storedStep = _prefs?.getInt('beginnerPathStep');
    if (storedStep != null) {
      beginnerPathStep = storedStep.clamp(0, 5);
    } else if (firstGestureDone) {
      beginnerPathStep = 5;
    } else {
      beginnerPathStep = 0;
    }
    // Keep unlock flag aligned with path completion.
    if (beginnerPathStep >= 5 && !firstGestureDone) {
      firstGestureDone = true;
    }
    seasonRewardIds
      ..clear()
      ..addAll(_prefs?.getStringList('seasonRewards') ?? const []);
    _restoreDaily();
    _restoreAchievements();
    _restoreHistory();
    _restoreOpenPosition();
    _restorePeakDd();
    _restoreMeta();
    _restoreSeasonProgress();
    timeframe = _prefs?.getString('timeframe') ?? '15m';
    weekEndsAt = SeasonClock.of(DateTime.now()).endsAt;
    _ensureSeasonProgress();
    _touchLoginStreak();
    _queueCommunityGateIfNeeded();

    try {
      var anyLive = false;
      for (final s in MarketFeed.symbols) {
        final loaded = await _feed.loadHistory(s.id, interval: timeframe);
        books[s.id] = loaded.candles;
        if (loaded.live) anyLive = true;
      }
      usedLiveFeed = anyLive;
      error = usedLiveFeed ? null : 'demo';
      _reconcileRestoredPositionMark();
      _deferStops = true;
      _startTicker();
      _startLeaguePulse();
      unawaited(_connectLiveTape());
    } catch (_) {
      for (final s in MarketFeed.symbols) {
        books[s.id] = _feed.generateVolatileSeries(
          start: s.start,
          step: MarketFeed.stepFor(timeframe),
        );
      }
      usedLiveFeed = false;
      error = 'demo';
      _reconcileRestoredPositionMark();
      _deferStops = true;
      _startTicker();
      _startLeaguePulse();
      unawaited(_connectLiveTape());
    } finally {
      loading = false;
      _checkAchievements(silent: true);
      _syncSeasonRewards();
      notifyListeners();
    }
  }

  void _restoreMeta() {
    final raw = _prefs?.getString('deskMeta');
    if (raw == null || raw.isEmpty) {
      meta = DeskMeta();
      return;
    }
    try {
      meta = DeskMeta.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      meta = DeskMeta();
    }
  }

  Future<void> _persistMeta() async {
    await _prefs?.setString('deskMeta', jsonEncode(meta.toJson()));
  }

  void _restoreSeasonProgress() {
    final raw = _prefs?.getString('seasonProgress');
    if (raw == null || raw.isEmpty) {
      seasonProgress = SeasonProgress();
      return;
    }
    try {
      seasonProgress = SeasonProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      seasonProgress = SeasonProgress();
    }
  }

  Future<void> _persistSeasonProgress() async {
    await _prefs?.setString('seasonProgress', jsonEncode(seasonProgress.toJson()));
  }

  void _ensureSeasonProgress() {
    final s = season;
    if (seasonProgress.seasonNumber != s.number) {
      // New season: keep shields leftover as one carry, reset XP/track/week.
      final carryShield = seasonProgress.streakShields.clamp(0, 1);
      seasonProgress = SeasonProgress(
        seasonNumber: s.number,
        streakShields: carryShield,
      );
      meta.creditsEarnedSeason = 0;
      meta.unlockedUpgrades.remove('up_season_boost');
      meta.unlockedUpgrades.remove('up_catchup_token');
      unawaited(_persistMeta());
      unawaited(_persistSeasonProgress());
    }
    final wk = weekKeyFor(s);
    if (seasonProgress.weekKey != wk) {
      seasonProgress.weekKey = wk;
      seasonProgress.weeklyProgress.clear();
      // Keep claimedWeekRewards history for badge, but new ids are week-scoped.
      unawaited(_persistSeasonProgress());
    }
  }

  List<WeeklyChallenge> get currentWeeklies => weeklyChallengesFor(season);

  String get seasonPressure => seasonPressureLine(
        season,
        ru: true,
        streak: meta.loginStreak,
        shields: seasonProgress.streakShields,
      );

  String seasonPressureFor(bool ru) => seasonPressureLine(
        season,
        ru: ru,
        streak: meta.loginStreak,
        shields: seasonProgress.streakShields,
      );

  bool get canClaimTodayTrack {
    final node = trackNodeForDay(season.day);
    if (node == null) return false;
    return !seasonProgress.claimedDay(season.day) && seasonProgress.daysActive >= 1;
  }

  void _touchLoginStreak() {
    final today = DailyDeskState.keyFor(DateTime.now().toUtc());
    if (meta.lastLoginDay == today) {
      // Still count active day for track once per day.
      return;
    }
    final yesterday = DailyDeskState.keyFor(DateTime.now().toUtc().subtract(const Duration(days: 1)));
    var broke = false;
    if (meta.lastLoginDay == yesterday) {
      meta.loginStreak = (meta.loginStreak + 1).clamp(1, 365);
    } else if (meta.lastLoginDay.isEmpty) {
      meta.loginStreak = 1;
    } else {
      // Missed at least one day.
      seasonProgress.missedYesterday = true;
      if (seasonProgress.streakShields > 0) {
        seasonProgress.streakShields -= 1;
        // Soft keep streak with shield.
        meta.loginStreak = (meta.loginStreak + 1).clamp(1, 365);
        Analytics.log('streak_shield_used');
      } else {
        broke = true;
        meta.loginStreak = 1;
        Analytics.log('streak_broke');
      }
    }
    meta.lastLoginDay = today;
    seasonProgress.daysActive += 1;
    if (meta.loginStreak >= 7) seasonRewardIds.add('sr_streak7');
    if (meta.loginStreak >= 14) seasonRewardIds.add('sr_streak14');
    // Milestone SP
    if (meta.loginStreak == 3 || meta.loginStreak == 7 || meta.loginStreak == 14) {
      _grantSeasonXp(meta.loginStreak == 3 ? 20 : meta.loginStreak == 7 ? 40 : 70, reason: 'streak_milestone');
    }
    if (!broke) {
      _grantSeasonXp(8, reason: 'login');
    }
    unawaited(_persistMeta());
    unawaited(_persistSeasonProgress());
    unawaited(_prefs?.setStringList('seasonRewards', seasonRewardIds.toList()));
  }

  void _grantSeasonXp(int amount, {String reason = ''}) {
    if (amount <= 0) return;
    var grant = (amount * phaseXpMult(season.phase)).round();
    if (meta.has('up_season_boost')) {
      grant = (grant * 1.15).round();
    }
    seasonProgress.seasonXp += grant;
    if (seasonProgress.seasonXp >= 200) {
      seasonRewardIds.add('sr_xp200');
    }
    unawaited(_persistSeasonProgress());
    Analytics.log('season_xp', {'n': grant, 'reason': reason, 'total': seasonProgress.seasonXp});
  }

  void _bumpWeekly(String kind, [int by = 1]) {
    for (final c in currentWeeklies) {
      final key = c.id.split('_').last;
      if (key != kind) continue;
      final cur = seasonProgress.weeklyProgress[c.id] ?? 0;
      if (cur >= c.target) continue;
      seasonProgress.weeklyProgress[c.id] = cur + by;
    }
    unawaited(_persistSeasonProgress());
    _tryClaimWeeklyRewards();
  }

  void _tryClaimWeeklyRewards() {
    var cleared = 0;
    for (final c in currentWeeklies) {
      final cur = seasonProgress.weeklyProgress[c.id] ?? 0;
      if (cur >= c.target && !seasonProgress.claimedWeekRewards.contains(c.id)) {
        seasonProgress.claimedWeekRewards.add(c.id);
        _grantCredits(c.rewardCredits, reason: 'weekly_${c.id}');
        _grantSeasonXp(c.rewardXp, reason: 'weekly_${c.id}');
        cleared++;
      }
    }
    if (cleared > 0 && currentWeeklies.every((c) => seasonProgress.claimedWeekRewards.contains(c.id))) {
      seasonRewardIds.add('sr_week_clear');
      unawaited(_prefs?.setStringList('seasonRewards', seasonRewardIds.toList()));
    }
  }

  Future<bool> claimTrackDay(int day, {bool catchUp = false}) async {
    final node = trackNodeForDay(day);
    if (node == null) return false;
    if (seasonProgress.claimedDay(day)) return false;
    final today = season.day;
    if (day > today) return false;
    if (day < today && !catchUp) return false;
    if (day == today && seasonProgress.daysActive < 1) return false;

    if (catchUp && day < today) {
      if (meta.has('up_catchup_token')) {
        meta.unlockedUpgrades.remove('up_catchup_token');
        await _persistMeta();
      } else {
        final cost = catchUpCostCredits(season.phase);
        if (meta.credits < cost) return false;
        meta.credits -= cost;
        await _persistMeta();
      }
    }

    seasonProgress.claimedDays.add(day);
    switch (node.kind) {
      case TrackRewardKind.credits:
        _grantCredits(node.amount, reason: 'track_$day');
      case TrackRewardKind.xp:
        _grantSeasonXp(node.amount, reason: 'track_$day');
      case TrackRewardKind.shield:
        seasonProgress.streakShields += node.amount;
      case TrackRewardKind.reroll:
        {
          meta.drillRerolls += node.amount;
          await _persistMeta();
        }
      case TrackRewardKind.ink:
        {
          seasonRewardIds.add('sr_contest');
          await _prefs?.setStringList('seasonRewards', seasonRewardIds.toList());
          _grantCredits(20, reason: 'track_ink');
        }
    }
    if (seasonProgress.claimedDays.length >= 8) {
      seasonRewardIds.add('sr_track14');
      await _prefs?.setStringList('seasonRewards', seasonRewardIds.toList());
    }
    await _persistSeasonProgress();
    Analytics.log('track_claim', {'day': day, 'catchUp': catchUp});
    notifyListeners();
    return true;
  }

  Future<bool> claimTodayTrack() => claimTrackDay(season.day);

  Future<void> _connectLiveTape() async {
    await _feed.liveTape.connect(activeSymbol);
    wsTapeLive = _feed.liveTape.isLive;
  }

  void consumeJuice() {
    pendingJuice = null;
  }

  Future<bool> buyUpgrade(String id) async {
    DeskUpgradeDef? def;
    for (final e in kDeskUpgrades) {
      if (e.id == id) {
        def = e;
        break;
      }
    }
    if (def == null) return false;
    if (meta.has(id)) return true;
    if (meta.credits < def.cost) return false;
    meta.credits -= def.cost;
    meta.unlockedUpgrades.add(id);
    if (id == 'up_drill_reroll') {
      meta.drillRerolls += 3;
    }
    if (id == 'up_streak_shield') {
      seasonProgress.streakShields += 2;
      await _persistSeasonProgress();
    }
    await _persistMeta();
    Analytics.log('upgrade_buy', {'id': id});
    notifyListeners();
    return true;
  }

  bool get hasTightRisk => meta.has('up_risk_tight');
  bool get hasHudPulse => meta.has('up_hud_pulse');
  int get playbookSlotBonus => meta.has('up_pb_slot') ? 2 : 0;

  Future<bool> spendDrillReroll() async {
    if (meta.drillRerolls <= 0) return false;
    meta.drillRerolls -= 1;
    await _persistMeta();
    notifyListeners();
    return true;
  }

  void _grantCredits(int amount, {String reason = ''}) {
    if (amount <= 0) return;
    var grant = (amount * phaseCreditMult(season.phase)).round();
    meta.credits += grant;
    meta.creditsEarnedSeason += grant;
    if (meta.creditsEarnedSeason >= 80) {
      seasonRewardIds.add('sr_credits');
    }
    unawaited(_persistMeta());
    Analytics.log('credits_grant', {'n': grant, 'reason': reason});
  }

  void _reconcileRestoredPositionMark() {
    final pos = position;
    if (pos == null) return;
    final book = books[pos.symbol];
    if (book == null || book.isEmpty) return;
    final pin = _restoredMark ?? pos.entry;
    books[pos.symbol] = _feed.pinLastClose(book, pin);
    pos.entryAbsIndex = max(0, books[pos.symbol]!.length - 2);
  }

  void _restorePeakDd() {
    peakEquity = _prefs?.getDouble('peakEquity') ?? max(peakEquity, cash);
    maxDrawdown = _prefs?.getDouble('maxDrawdown') ?? maxDrawdown;
  }

  void _restoreDaily() {
    final raw = _prefs?.getString('dailyJson');
    final utc = DateTime.now().toUtc();
    if (raw == null || raw.isEmpty) {
      daily = DailyDeskState.empty(utc);
      return;
    }
    try {
      daily = DailyDeskState.fromJson(jsonDecode(raw) as Map<String, dynamic>, utc);
    } catch (_) {
      daily = DailyDeskState.empty(utc);
    }
  }

  Future<void> _persistDaily() async {
    await _prefs?.setString('dailyJson', jsonEncode(daily.toJson()));
  }

  Future<void> _markDaily(DailyDeskState next) async {
    final was = daily.complete;
    daily = next;
    await _persistDaily();
    if (!was && daily.complete) {
      discipline = (discipline + 2).clamp(0, 100);
      await _prefs?.setInt('discipline', discipline);
      var bonus = 25;
      if (season.phase == SeasonPhase.contest) bonus += 10;
      if (season.phase == SeasonPhase.finals) bonus += 20;
      bonus += (meta.loginStreak ~/ 3).clamp(0, 20);
      _grantCredits(bonus, reason: 'daily_complete');
      _grantSeasonXp(25, reason: 'daily_complete');
      _bumpWeekly('dailies');
      if (fullTerminalUnlocked) {
        habitDesksDone += 1;
        await _prefs?.setInt('habitDesksDone', habitDesksDone);
        Analytics.log('daily_desk_complete', {'habit': habitDesksDone, 'stage': journeyStage});
      }
    }
    notifyListeners();
  }

  Future<void> markDailyPlannedTrade() => _markDaily(daily.copyWith(plannedTrade: true));
  Future<void> markDailyCleanStop() => _markDaily(daily.copyWith(cleanStop: true));
  Future<void> markDailyDrill() => _markDaily(daily.copyWith(drillDone: true));
  Future<void> markDailyShare() async {
    await _markDaily(daily.copyWith(sharedCard: true));
    _bumpWeekly('shares');
    _grantSeasonXp(8, reason: 'share');
  }

  void _syncSeasonRewards() {
    for (final r in seasonRewards) {
      if (r.unlocked) seasonRewardIds.add(r.id);
    }
    unawaited(_prefs?.setStringList('seasonRewards', seasonRewardIds.toList()));
  }

  void _startLeaguePulse() {
    _leagueTimer?.cancel();
    // Seed prev without deltas, then publish first frame.
    leaguePulse.commitSnapshot(_rawBoard());
    _publishLeagueBoard();
    _leagueTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      leaguePulse.tick(_rng, season);
      _publishLeagueBoard();
      _leaguePulseEvery++;
      if (_leaguePulseEvery % 2 == 0) {
        unawaited(noteSeasonRank(yourRank));
      }
      notifyListeners();
    });
  }

  ClosedTrade? consumeRecap() {
    final t = lastRecap;
    lastRecap = null;
    return t;
  }

  ClosedTrade? consumeShareRitual() {
    final t = pendingShareRitual;
    pendingShareRitual = null;
    return t;
  }

  Future<void> markTapeDrillIntroSeen() async {
    tapeDrillIntroSeen = true;
    await _prefs?.setBool('tapeDrillIntro', true);
    notifyListeners();
  }

  Future<void> markPlaybooksIntroSeen() async {
    playbooksIntroSeen = true;
    await _prefs?.setBool('playbooksIntro', true);
    notifyListeners();
  }

  List<String> consumeAchievements() {
    final list = List<String>.from(pendingAchievements);
    pendingAchievements.clear();
    return list;
  }

  void _restoreAchievements() {
    final raw = _prefs?.getStringList('achievements');
    unlockedAchievements
      ..clear()
      ..addAll(raw ?? const []);
  }

  Future<void> _persistAchievements() async {
    await _prefs?.setStringList('achievements', unlockedAchievements.toList());
  }

  void _checkAchievements({ClosedTrade? justClosed, bool silent = false}) {
    final newly = evaluateAchievements(
      already: unlockedAchievements,
      history: history,
      discipline: discipline,
      justClosed: justClosed,
    );
    if (newly.isEmpty) return;
    unlockedAchievements.addAll(newly);
    if (!silent) pendingAchievements = newly;
    unawaited(_persistAchievements());
  }

  void _restoreHistory() {
    final raw = _prefs?.getString('historyJson');
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      history
        ..clear()
        ..addAll(list.map((e) => _tradeFromJson(e as Map<String, dynamic>)));
    } catch (_) {}
    final eq = _prefs?.getDouble('cash');
    if (eq != null) cash = eq;
    final curve = _prefs?.getString('equityCurve');
    if (curve != null) {
      try {
        equityCurve
          ..clear()
          ..addAll((jsonDecode(curve) as List).map((e) => (e as num).toDouble()));
      } catch (_) {}
    }
  }

  void _restoreOpenPosition() {
    final raw = _prefs?.getString('openPos');
    if (raw == null || raw.isEmpty) return;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      position = Position(
        id: m['id'] as String,
        symbol: m['symbol'] as String,
        side: (m['side'] as String) == 'short' ? Side.short : Side.long,
        qty: (m['qty'] as num).toDouble(),
        entry: (m['entry'] as num).toDouble(),
        openedAt: DateTime.parse(m['oa'] as String),
        stop: (m['stop'] as num).toDouble(),
        tp: (m['tp'] as num?)?.toDouble(),
        initialStop: (m['istop'] as num?)?.toDouble(),
        mfe: (m['mfe'] as num?)?.toDouble() ?? 0,
        mae: (m['mae'] as num?)?.toDouble() ?? 0,
        entryAbsIndex: m['eai'] as int? ?? 0,
      );
      activeSymbol = position!.symbol;
      _widenedStop = m['widen'] as bool? ?? false;
      _restoredMark = (m['mark'] as num?)?.toDouble();
    } catch (_) {
      position = null;
      _restoredMark = null;
    }
  }

  Future<void> _persist() async {
    final p = _prefs;
    if (p == null) return;
    await p.setDouble('cash', cash);
    await p.setInt('discipline', discipline);
    await p.setBool('tutorialTrade', tutorialTrade);
    await p.setBool('tutorialStopSet', tutorialStopSet);
    await p.setBool('firstGesture', firstGestureDone);
    await p.setInt('beginnerPathStep', beginnerPathStep);
    await p.setBool('communityGateShown', communityGateShown);
    await p.setBool('communityGateAccepted', communityGateAccepted);
    await p.setBool('communityGateDismissed', communityGateDismissed);
    await p.setBool('firstWinCeremonySeen', firstWinCeremonySeen);
    await p.setBool('softAuthPromptSeen', softAuthPromptSeen);
    await p.setInt('orientStep', orientStep);
    await p.setBool('phase2BridgeSeen', phase2BridgeSeen);
    await p.setBool('phase3BridgeSeen', phase3BridgeSeen);
    await p.setInt('phase3Step', phase3Step);
    await p.setBool('leagueIntroSeen', leagueIntroSeen);
    await p.setBool('glossarySeen', glossarySeen);
    await p.setBool('phase4BridgeSeen', phase4BridgeSeen);
    await p.setBool('phase5BridgeSeen', phase5BridgeSeen);
    await p.setBool('phase6BridgeSeen', phase6BridgeSeen);
    await p.setBool('shortTeachDone', shortTeachDone);
    await p.setBool('move1ReplaySeen', move1ReplaySeen);
    await p.setInt('move1Copies', move1Copies);
    await p.setInt('habitDesksDone', habitDesksDone);
    await p.setInt('habitViewDay', habitViewDay);
    await p.setBool('moveCopyTrade', moveCopyTrade);
    if (tutorialRiskPct > 0) await p.setDouble('tutorialRiskPct', tutorialRiskPct);
    await p.setDouble('peakEquity', peakEquity);
    await p.setDouble('maxDrawdown', maxDrawdown);
    await p.setString('timeframe', timeframe);
    await p.setString(
      'historyJson',
      jsonEncode(history.take(80).map(_tradeToJson).toList()),
    );
    await p.setString('equityCurve', jsonEncode(equityCurve.takeLast(120).toList()));
    final pos = position;
    if (pos == null) {
      await p.remove('openPos');
    } else {
      await p.setString(
        'openPos',
        jsonEncode({
          'id': pos.id,
          'symbol': pos.symbol,
          'side': pos.side.name,
          'qty': pos.qty,
          'entry': pos.entry,
          'oa': pos.openedAt.toIso8601String(),
          'stop': pos.stop,
          'tp': pos.tp,
          'istop': pos.initialStop,
          'widen': _widenedStop,
          'mfe': pos.mfe,
          'mae': pos.mae,
          'eai': pos.entryAbsIndex,
          'mark': _markFor(pos.symbol),
        }),
      );
    }
  }

  Map<String, dynamic> _tradeToJson(ClosedTrade t) => {
        'id': t.id,
        'symbol': t.symbol,
        'side': t.side.name,
        'qty': t.qty,
        'entry': t.entry,
        'exit': t.exit,
        'pnl': t.pnl,
        'r': t.rMultiple,
        'oa': t.openedAt.toIso8601String(),
        'ca': t.closedAt.toIso8601String(),
        'delta': t.scoreDelta,
        'tip': t.tip,
        'stop': t.stop,
        'tp': t.tp,
        'mfe': t.mfe,
        'mae': t.mae,
        'kind': t.exitKind.name,
        'ei': t.entryIndex,
        'xi': t.exitIndex,
        'widen': t.widenedStop,
        'flags': t.flags.map((f) => f.name).toList(),
        'tape': t.tape.map((c) => c.toJson()).toList(),
      };

  Set<RecapFlag> _flagsFromJson(dynamic raw) {
    if (raw is! List) {
      return {RecapFlag.stopSet, RecapFlag.sizeOk, RecapFlag.noWiden, RecapFlag.noRevenge};
    }
    final out = <RecapFlag>{};
    for (final e in raw) {
      final name = e.toString();
      for (final f in RecapFlag.values) {
        if (f.name == name) out.add(f);
      }
    }
    return out;
  }

  ClosedTrade _tradeFromJson(Map<String, dynamic> m) {
    final tapeRaw = m['tape'] as List<dynamic>?;
    return ClosedTrade(
      id: m['id'] as String,
      symbol: m['symbol'] as String,
      side: (m['side'] as String) == 'short' ? Side.short : Side.long,
      qty: (m['qty'] as num).toDouble(),
      entry: (m['entry'] as num).toDouble(),
      exit: (m['exit'] as num).toDouble(),
      pnl: (m['pnl'] as num).toDouble(),
      rMultiple: (m['r'] as num).toDouble(),
      openedAt: DateTime.parse(m['oa'] as String),
      closedAt: DateTime.parse(m['ca'] as String),
      flags: _flagsFromJson(m['flags']),
      scoreDelta: m['delta'] as int? ?? 0,
      tip: m['tip'] as String? ?? '',
      stop: (m['stop'] as num?)?.toDouble(),
      tp: (m['tp'] as num?)?.toDouble(),
      mfe: (m['mfe'] as num?)?.toDouble() ?? 0,
      mae: (m['mae'] as num?)?.toDouble() ?? 0,
      exitKind: switch (m['kind'] as String?) {
        'stop' => TradeExitKind.stop,
        'tp' => TradeExitKind.tp,
        'partial' => TradeExitKind.partial,
        _ => TradeExitKind.manual,
      },
      entryIndex: m['ei'] as int? ?? 0,
      exitIndex: m['xi'] as int? ?? 0,
      widenedStop: m['widen'] as bool? ?? false,
      tape: tapeRaw
              ?.map((e) => Candle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Future<void> setNickname(String value) async {
    final next = value.trim();
    if (next.isEmpty || next.length > 18) return;
    nickname = next;
    await _prefs?.setString('nickname', nickname);
    unawaited(_leagueRepo?.upsertProfile(nickname: nickname, hue: avatarHue));
    notifyListeners();
  }

  Future<void> setAvatarPath(String? path) async {
    avatarPath = path;
    if (path == null) {
      await _prefs?.remove('avatarPath');
    } else {
      await _prefs?.setString('avatarPath', path);
    }
    notifyListeners();
  }

  Future<void> setAvatarHue(int hue) async {
    avatarHue = hue % 360;
    await _prefs?.setInt('avatarHue', avatarHue);
    unawaited(_leagueRepo?.upsertProfile(nickname: nickname, hue: avatarHue));
    notifyListeners();
  }

  Future<void> completeCoach() async {
    coachDone = true;
    await _prefs?.setBool('coachDone', true);
    notifyListeners();
  }

  Future<void> switchSymbol(String id) async {
    if (id == activeSymbol) return;
    if (position != null && position!.symbol != id) {
      // Keep position; switching chart is allowed for research
    }
    activeSymbol = id;
    if (activePlaybookLevels != null) {
      activePlaybookLevels = null;
      playbookSeedToken++;
    }
    unawaited(_connectLiveTape());
    notifyListeners();
  }

  void _startTicker() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(milliseconds: 380), (_) => _onTick());
  }

  void _onTick() {
    previousMark = mark;
    final tape = _feed.liveTape;
    wsTapeLive = tape.isLive;
    for (final id in books.keys) {
      final list = books[id];
      if (list == null || list.isEmpty) continue;
      Candle updated;
      if (id == activeSymbol && tape.isLive && tape.lastPrice != null) {
        updated = _feed.applyLivePrice(list.last, tape.lastPrice!);
      } else {
        updated = _feed.tickLive(list.last);
      }
      final next = [...list.sublist(0, list.length - 1), updated];
      if (_rng.nextDouble() < 0.045) {
        final last = next.last;
        next.add(
          Candle(
            openTime: last.openTime.add(_tfDuration),
            open: last.close,
            high: last.close,
            low: last.close,
            close: last.close,
            volume: 10 + _rng.nextDouble() * 30,
          ),
        );
        if (next.length > 260) {
          final drop = next.length - 220;
          books[id] = next.sublist(drop);
          final pos = position;
          if (pos != null && pos.symbol == id) {
            pos.entryAbsIndex = max(0, pos.entryAbsIndex - drop);
          }
        } else {
          books[id] = next;
        }
      } else {
        books[id] = next;
      }
    }

    if (mark > previousMark) {
      markDir = 1;
    } else if (mark < previousMark) {
      markDir = -1;
    }

    _checkStops();
    _trackExcursion();
    _updateDrawdown();
    if (equityCurve.isEmpty || (equity - equityCurve.last).abs() > 0.5) {
      equityCurve.add(equity);
      if (equityCurve.length > 160) {
        equityCurve.removeRange(0, equityCurve.length - 140);
      }
    }
    notifyListeners();
  }

  Duration get _tfDuration => MarketFeed.stepFor(timeframe);

  /// Switch candle timeframe without moving the live mark or closing risk.
  Future<void> setTimeframe(String tf) async {
    if (tf == timeframe) return;
    final preserved = <String, double>{};
    for (final s in MarketFeed.symbols) {
      final book = books[s.id];
      preserved[s.id] = (book != null && book.isNotEmpty) ? book.last.close : s.start;
    }
    timeframe = tf;
    _deferStops = true;

    // Instant local rebuild — mark pinned flat so stops cannot false-fire.
    for (final s in MarketFeed.symbols) {
      final markPx = preserved[s.id]!;
      books[s.id] = _feed.bookForTimeframe(mark: markPx, timeframe: tf);
    }

    final pos = position;
    if (pos != null) {
      final book = books[pos.symbol];
      if (book != null && book.isNotEmpty) {
        pos.entryAbsIndex = max(0, book.length - 2);
      }
    }
    await _prefs?.setString('timeframe', timeframe);
    notifyListeners();

    // When flat, optionally hydrate from Binance for this TF (still pin mark).
    if (pos == null) {
      unawaited(_hydrateTimeframeFromRemote(preserved));
    }
    unawaited(_connectLiveTape());
  }

  Future<void> _hydrateTimeframeFromRemote(Map<String, double> preserved) async {
    var anyLive = false;
    for (final s in MarketFeed.symbols) {
      try {
        final loaded = await _feed.loadHistory(s.id, interval: timeframe);
        if (!loaded.live) continue;
        anyLive = true;
        final markPx = books[s.id]?.last.close ?? preserved[s.id] ?? s.start;
        books[s.id] = _feed.pinLastClose(loaded.candles, markPx);
      } catch (_) {}
    }
    if (anyLive) {
      usedLiveFeed = true;
      error = null;
      notifyListeners();
    }
  }

  void _trackExcursion() {
    final pos = position;
    if (pos == null) return;
    final list = books[pos.symbol];
    if (list == null || list.isEmpty) return;
    pos.trackExcursion(list.last);
  }

  void _updateDrawdown() {
    if (equity > peakEquity) peakEquity = equity;
    final dd = (peakEquity - equity) / peakEquity * 100;
    if (dd > maxDrawdown) maxDrawdown = dd;
  }

  void _checkStops() {
    if (_deferStops) {
      _deferStops = false;
      return;
    }
    if (tutorialTrade || moveCopyTrade) return;
    final pos = position;
    if (pos == null) return;
    final c = books[pos.symbol];
    if (c == null || c.isEmpty) return;
    final last = c.last;
    if (pos.hitStop(last.high, last.low)) {
      closePosition(exitOverride: pos.stop, kind: TradeExitKind.stop);
      return;
    }
    if (pos.tp != null && pos.hitTp(last.high, last.low)) {
      closePosition(exitOverride: pos.tp!, kind: TradeExitKind.tp);
    }
  }

  double qtyForRisk({
    required Side side,
    required double entry,
    required double stop,
    required double riskPct,
  }) {
    final dist = (entry - stop).abs();
    if (dist <= 0) return 0;
    return equity * riskPct / dist;
  }

  String? placeMarket({
    required Side side,
    required double riskPct,
    required double stop,
    double? tp,
    double? entryOverride,
    double? qtyOverride,
    bool tutorial = false,
  }) {
    if (position != null) return 'close_first';
    if (candles.isEmpty && (moveTeachCandles == null || moveTeachCandles!.isEmpty)) {
      return 'no_data';
    }
    final entry = entryOverride ?? mark;
    if (side == Side.long && stop >= entry) return 'stop_long';
    if (side == Side.short && stop <= entry) return 'stop_short';

    final clampedRisk = riskPct.clamp(0.005, 0.05);
    var qty = qtyOverride ??
        qtyForRisk(side: side, entry: entry, stop: stop, riskPct: clampedRisk);
    if (qty * entry * (1 + MarketFeed.feeRate) > cash) {
      qty = (cash * 0.98) / entry;
    }
    if (qty <= 0) return 'size_small';

    cash -= qty * entry * (1 + MarketFeed.feeRate);
    _widenedStop = false;
    _tradesLast10Min += 1;
    Future.delayed(const Duration(minutes: 10), () {
      _tradesLast10Min = max(0, _tradesLast10Min - 1);
    });

    position = Position(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      symbol: activeSymbol,
      side: side,
      qty: qty,
      entry: entry,
      openedAt: DateTime.now(),
      stop: stop,
      tp: tp,
      entryAbsIndex: max(0, candles.length - 1),
    );
    tutorialTrade = tutorial;
    tutorialStopSet = tutorial ? false : true;
    if (!tutorial && !coachDone) unawaited(completeCoach());
    unawaited(DeskAudio.instance.play(DeskSfx.fill));
    position?.trackExcursion(candles.last);
    if (!tutorial && !firstStopTradeDone) {
      firstStopTradeDone = true;
      unawaited(_prefs?.setBool('firstStopTrade', true));
    }
    Analytics.log('trade_open', {'side': side.name});
    unawaited(_persist());
    pendingJuice = 'fill';
    notifyListeners();
    return null;
  }

  void updateStop(double next) {
    final pos = position;
    if (pos == null) return;
    // Keep stop on the protective side of entry.
    if (pos.side == Side.long && next >= pos.entry) return;
    if (pos.side == Side.short && next <= pos.entry) return;
    final worse = pos.side == Side.long ? next < pos.stop : next > pos.stop;
    if (worse) _widenedStop = true;
    pos.stop = next;
    unawaited(_persist());
    notifyListeners();
  }

  void updateTp(double? next) {
    final pos = position;
    if (pos == null || next == null) return;
    if (pos.side == Side.long && next <= pos.entry) return;
    if (pos.side == Side.short && next >= pos.entry) return;
    pos.tp = next;
    unawaited(_persist());
    notifyListeners();
  }

  ClosedTrade? closePartial(double fraction) {
    final pos = position;
    if (pos == null) return null;
    final f = fraction.clamp(0.05, 1.0);
    if (f >= 0.999) return closePosition();

    final m = _markFor(pos.symbol);
    final closeQty = pos.qty * f;
    final gross = pos.side == Side.long ? (m - pos.entry) * closeQty : (pos.entry - m) * closeQty;
    final fee = m * closeQty * MarketFeed.feeRate;
    final pnl = gross - fee;
    cash += closeQty * pos.entry + gross - fee;

    final snap = _buildTapeSnapshot(pos, m);
    position = Position(
      id: pos.id,
      symbol: pos.symbol,
      side: pos.side,
      qty: pos.qty - closeQty,
      entry: pos.entry,
      openedAt: pos.openedAt,
      stop: pos.stop,
      tp: pos.tp,
      initialStop: pos.initialStop,
      mfe: snap.mfe,
      mae: snap.mae,
      entryAbsIndex: pos.entryAbsIndex,
    );

    final trade = ClosedTrade(
      id: '${pos.id}_p',
      symbol: pos.symbol,
      side: pos.side,
      qty: closeQty,
      entry: pos.entry,
      exit: m,
      pnl: pnl,
      rMultiple: pos.rMultiple(m),
      openedAt: pos.openedAt,
      closedAt: DateTime.now(),
      flags: {RecapFlag.stopSet, RecapFlag.sizeOk, RecapFlag.noWiden, RecapFlag.noRevenge},
      scoreDelta: 1,
      tip: 'Partial secured. Trail the runner with a tight stop.',
      stop: pos.stop,
      tp: pos.tp,
      mfe: snap.mfe,
      mae: snap.mae,
      exitKind: TradeExitKind.partial,
      tape: snap.tape,
      entryIndex: snap.entryIndex,
      exitIndex: snap.exitIndex,
      widenedStop: _widenedStop,
    );
    history.insert(0, trade);
    lastRecap = trade;
    discipline = (discipline + 1).clamp(0, 100);
    _checkAchievements(justClosed: trade);
    unawaited(DeskAudio.instance.play(pnl >= 0 ? DeskSfx.win : DeskSfx.loss));
    unawaited(_persist());
    notifyListeners();
    return trade;
  }

  Future<void> ensureBeginnerPathStarted() async {
    if (beginnerPathStep != 0) return;
    beginnerPathStep = 1;
    await _prefs?.setInt('beginnerPathStep', 1);
    notifyListeners();
  }

  Future<void> completeCandleMission() async {
    if (beginnerPathStep > 1) return;
    beginnerPathStep = 2;
    await _prefs?.setInt('beginnerPathStep', 2);
    Analytics.log('mission_1_complete');
    notifyListeners();
  }

  /// Fixed practice size for mission 2: ~90% of cash, rounded down to 2 significant digits.
  double get tutorialQtyPreview {
    final entry = mark;
    if (entry <= 0) return 0;
    final raw = cash * 0.9 / entry;
    if (raw <= 0) return 0;
    final mag = pow(10, (log(raw) / ln10).floor() - 1).toDouble();
    return (raw / mag).floorToDouble() * mag;
  }

  /// Stop price that risks [riskPct] of equity on the open tutorial position.
  double? tutorialStopFor(double riskPct) {
    final pos = position;
    if (pos == null || pos.qty <= 0) return null;
    final dist = equity * riskPct / pos.qty;
    return pos.side == Side.long ? pos.entry - dist : pos.entry + dist;
  }

  Future<void> ensureTutorialTrade() async {
    if (!beginnerPathActive || position != null || candles.isEmpty) return;
    if (beginnerPathStep < 2) return;
    final entry = mark;
    if (entry <= 0) return;
    final qty = tutorialQtyPreview;
    if (qty <= 0) return;
    final err = placeMarket(
      side: Side.long,
      riskPct: 0.005,
      stop: entry * 0.55,
      qtyOverride: qty,
      tutorial: true,
    );
    if (err != null) return;
    if (beginnerPathStep < 3) {
      beginnerPathStep = 3;
      await _prefs?.setInt('beginnerPathStep', 3);
      Analytics.log('mission_2_trade_open');
      notifyListeners();
    }
  }

  void placeTutorialStop({double riskPct = 0.01}) {
    final pos = position;
    if (pos == null || !tutorialTrade) return;
    final next = tutorialStopFor(riskPct);
    if (next == null || next <= 0) return;
    pos.stop = next;
    tutorialRiskPct = riskPct;
    unawaited(_prefs?.setDouble('tutorialRiskPct', riskPct));
    tutorialStopSet = true;
    firstStopTradeDone = true;
    unawaited(_prefs?.setBool('firstStopTrade', true));
    if (beginnerPathStep < 4) {
      beginnerPathStep = 4;
      unawaited(_prefs?.setInt('beginnerPathStep', 4));
      Analytics.log('mission_3_stop');
    }
    unawaited(_persist());
    notifyListeners();
  }

  /// Mission 4 "Got it": unlocks the desk. The flow screen runs its own ceremony.
  Future<void> finishBeginnerPath() async {
    lastTutorialTrade = null;
    await completeFirstGesture(queueCeremonies: false);
  }

  Future<void> setReminderHour(int? hour) async {
    reminderHour = hour;
    if (hour == null) {
      await _prefs?.remove('reminderHour');
    } else {
      await _prefs?.setInt('reminderHour', hour);
      Analytics.log('reminder_opt_in', {'hour': hour});
    }
    notifyListeners();
  }

  Future<void> advanceOrientation() async {
    if (orientStep >= 3) return;
    orientStep += 1;
    await _prefs?.setInt('orientStep', orientStep);
    final event = switch (orientStep) {
      1 => 'orient_chart_seen',
      2 => 'orient_btc_seen',
      3 => 'orient_candle_seen',
      _ => 'orient_step',
    };
    Analytics.log(event);
    notifyListeners();
  }

  Future<void> markPhase2BridgeSeen() async {
    phase2BridgeSeen = true;
    await _prefs?.setBool('phase2BridgeSeen', true);
    Analytics.log('bridge_seen');
    notifyListeners();
  }

  Future<void> advancePhase3() async {
    if (phase3Step >= 4) return;
    phase3Step += 1;
    await _prefs?.setInt('phase3Step', phase3Step);
    Analytics.log('phase3_step', {'step': phase3Step});
    notifyListeners();
  }

  Future<void> completePhase3Bridge({int goToTab = 2}) async {
    phase3BridgeSeen = true;
    phase3Step = 4;
    pendingShellTab = goToTab;
    await _prefs?.setBool('phase3BridgeSeen', true);
    await _prefs?.setInt('phase3Step', phase3Step);
    Analytics.log('phase3_bridge_done', {'tab': goToTab});
    notifyListeners();
  }

  Future<void> markLeagueIntroSeen() async {
    leagueIntroSeen = true;
    await _prefs?.setBool('leagueIntroSeen', true);
    Analytics.log('league_intro_seen');
    notifyListeners();
  }

  Future<void> markGlossarySeen() async {
    glossarySeen = true;
    await _prefs?.setBool('glossarySeen', true);
    Analytics.log('glossary_seen');
    notifyListeners();
  }

  Future<void> completePhase4Bridge() async {
    phase4BridgeSeen = true;
    await _prefs?.setBool('phase4BridgeSeen', true);
    Analytics.log('phase4_bridge_done');
    notifyListeners();
  }

  Future<void> completePhase5Bridge({bool goToShort = true}) async {
    phase5BridgeSeen = true;
    await _prefs?.setBool('phase5BridgeSeen', true);
    Analytics.log('phase5_bridge_done');
    notifyListeners();
  }

  Future<void> completePhase6Bridge() async {
    phase6BridgeSeen = true;
    await _prefs?.setBool('phase6BridgeSeen', true);
    Analytics.log('phase6_bridge_done');
    notifyListeners();
  }

  Future<void> markShortTeachDone() async {
    shortTeachDone = true;
    await _prefs?.setBool('shortTeachDone', true);
    Analytics.log('short_teach_done');
    notifyListeners();
  }

  void requestShellTab(int tab) {
    pendingShellTab = tab;
    notifyListeners();
  }

  int? consumePendingShellTab() {
    final t = pendingShellTab;
    pendingShellTab = null;
    return t;
  }

  Future<void> markMove1ReplaySeen() async {
    move1ReplaySeen = true;
    await _prefs?.setBool('move1ReplaySeen', true);
    Analytics.log('move_1_replay');
    notifyListeners();
  }

  void startTodaySession() {
    todaySessionActive = true;
    notifyListeners();
  }

  void endTodaySession({bool countDesk = false}) {
    todaySessionActive = false;
    if (countDesk) {
      habitDesksDone += 1;
      // Keep the hub on the day just finished so the next-day button appears.
      if (habitViewDay < habitDesksDone) {
        habitViewDay = habitDesksDone;
      }
      unawaited(_prefs?.setInt('habitDesksDone', habitDesksDone));
      unawaited(_prefs?.setInt('habitViewDay', habitViewDay));
      unawaited(Analytics.log('daily_desk_complete', {'habit': habitDesksDone}));
      _queueCommunityGateIfNeeded();
    }
    notifyListeners();
  }

  Future<void> advanceHabitViewDay() async {
    if (!canAdvanceHabitDay) return;
    habitViewDay = (habitViewDay + 1).clamp(1, 28);
    await _prefs?.setInt('habitViewDay', habitViewDay);
    Analytics.log('habit_day_advance', {'day': habitViewDay});
    notifyListeners();
  }

  /// Build / refresh a day-specific bounce chart for move replay + copy.
  /// Stable for the session — call once when opening the flow, not after close.
  void prepareMoveTeach({int? day, int salt = 0, bool force = false, bool short = false}) {
    if (!force && moveTeachCandles != null && moveTeachCandles!.isNotEmpty) return;
    final d = day ?? habitViewDay;
    // Day-stable salt so reopening the same day doesn't swap the picture mid-lesson.
    final s = salt != 0 ? salt : d * 31 + habitDesksDone * 7;
    final base = (candles.isNotEmpty ? candles.last.close : 56000.0).clamp(1000.0, 1e7);
    final raw = BounceScenario.forDay(d, salt: s);
    final scenario = short ? raw.asShort : raw;
    teachIsShort = short;
    moveTeachScenarioId = scenario.id;
    moveTeachCandles = scenario.candles(base: base, seed: s ^ (base * 10).round() ^ (short ? 0x51 : 0));
    moveTeachBuy = scenario.buyPrice(base: base);
    _teachTick = 0;
    notifyListeners();
  }

  void clearMoveTeach() {
    moveTeachCandles = null;
    moveTeachBuy = null;
    teachIsShort = false;
    _teachTick = 0;
  }

  /// Live microstructure on the teaching chart — call from a UI timer.
  void tickMoveTeach() {
    final list = moveTeachCandles;
    if (list == null || list.isEmpty) return;
    _teachTick += 1;
    final buy = moveTeachBuy ?? list.last.close;
    final last = list.last;
    final px = last.close;
    // After entry: grind toward a small target. Before: breathe + drift into the zone.
    final double drift;
    if (moveCopyTrade && position != null) {
      final target = teachIsShort ? position!.entry * 0.99 : position!.entry * 1.01;
      drift = (target - px) * 0.08 + (_rng.nextDouble() - 0.45) * px * 0.00025;
    } else {
      drift = (buy - px) * 0.03 + (_rng.nextDouble() - 0.5) * px * 0.0004;
    }
    var next = px + drift;
    // Seal forming candle every ~8 ticks and open a new one (feels like 5m prints).
    if (_teachTick % 8 == 0) {
      final sealed = Candle(
        openTime: last.openTime,
        open: last.open,
        high: max(last.high, next),
        low: min(last.low, next),
        close: next,
        volume: last.volume + _rng.nextDouble() * 20,
      );
      list[list.length - 1] = sealed;
      final open = next * (1 + (_rng.nextDouble() - 0.5) * 0.0002);
      list.add(
        Candle(
          openTime: last.openTime.add(const Duration(minutes: 5)),
          open: open,
          high: open,
          low: open,
          close: open,
          volume: 60 + _rng.nextDouble() * 40,
        ),
      );
      // Keep chart length bounded.
      if (list.length > 64) {
        moveTeachCandles = list.sublist(list.length - 56);
      }
    } else {
      list[list.length - 1] = Candle(
        openTime: last.openTime,
        open: last.open,
        high: max(last.high, next),
        low: min(last.low, next),
        close: next,
        volume: last.volume + _rng.nextDouble() * 4,
      );
    }
    notifyListeners();
  }

  /// Open a guided Long (or Short when [teachIsShort]) for paper copy.
  Future<void> ensureMove1Trade() async {
    if (position != null) return;
    if (moveTeachCandles == null || moveTeachCandles!.isEmpty) {
      prepareMoveTeach(force: true, short: teachIsShort);
    }
    if (candles.isEmpty && (moveTeachCandles == null || moveTeachCandles!.isEmpty)) return;
    final entry = moveTeachCandles?.last.close ?? mark;
    if (entry <= 0) return;
    final qty = tutorialQtyPreview;
    if (qty <= 0) return;
    final err = placeMarket(
      side: teachIsShort ? Side.short : Side.long,
      riskPct: 0.01,
      stop: teachIsShort ? entry * 1.45 : entry * 0.55,
      qtyOverride: qty,
      entryOverride: entry,
      tutorial: false,
    );
    if (err != null) return;
    // placeMarket marks a normal trade as stop-ready; guided copy overrides that.
    moveCopyTrade = true;
    tutorialTrade = false;
    tutorialStopSet = false;
    await _prefs?.setBool('moveCopyTrade', true);
    Analytics.log(teachIsShort ? 'short_teach_open' : 'move_1_trade_open');
    notifyListeners();
  }

  void placeMove1Stop({double riskPct = 0.01}) {
    final pos = position;
    if (pos == null || !moveCopyTrade) return;
    final next = tutorialStopFor(riskPct);
    if (next == null || next <= 0) return;
    pos.stop = next;
    tutorialRiskPct = riskPct;
    tutorialStopSet = true;
    unawaited(_prefs?.setDouble('tutorialRiskPct', riskPct));
    unawaited(_persist());
    Analytics.log('move_1_stop');
    notifyListeners();
  }

  ClosedTrade? _closeMoveCopy(Position pos, double? exitOverride) {
    // Teaching close: small target in the trade's favor when no override.
    final exit = exitOverride ??
        (teachIsShort ? pos.entry * 0.988 : pos.entry * 1.012);
    final fee = exit * pos.qty * MarketFeed.feeRate;
    final gross = pos.side == Side.long
        ? (exit - pos.entry) * pos.qty
        : (pos.entry - exit) * pos.qty;
    final pnl = gross - fee;
    cash += pos.qty * pos.entry + gross - fee;
    final snap = _buildTapeSnapshot(pos, exit);
    final trade = ClosedTrade(
      id: pos.id,
      symbol: pos.symbol,
      side: pos.side,
      qty: pos.qty,
      entry: pos.entry,
      exit: exit,
      pnl: pnl,
      rMultiple: pos.rMultiple(exit),
      openedAt: pos.openedAt,
      closedAt: DateTime.now(),
      flags: const {RecapFlag.stopSet, RecapFlag.sizeOk, RecapFlag.noWiden, RecapFlag.noRevenge},
      scoreDelta: 6,
      tip: teachIsShort
          ? 'Short copy done. Fade = sell the rejection, stop above.'
          : 'Move copy done. Same motion you will see live in Desk Club.',
      stop: pos.stop,
      tp: pos.tp,
      mfe: snap.mfe,
      mae: snap.mae,
      exitKind: TradeExitKind.manual,
      tape: snap.tape,
      entryIndex: snap.entryIndex,
      exitIndex: snap.exitIndex,
    );
    history.insert(0, trade);
    lastRecap = null;
    pendingShareRitual = null;
    position = null;
    moveCopyTrade = false;
    tutorialStopSet = false;
    // Keep teaching candles until the next prepareMoveTeach(force) —
    // clearing here flashed a different (live) chart on the close frame.
    if (teachIsShort) {
      shortTeachDone = true;
      unawaited(_prefs?.setBool('shortTeachDone', true));
      unawaited(Analytics.log('short_teach_copy'));
    } else {
      move1Copies += 1;
      unawaited(_prefs?.setInt('move1Copies', move1Copies));
      unawaited(Analytics.log('move_1_copy', {'n': move1Copies}));
    }
    unawaited(_prefs?.setBool('moveCopyTrade', false));
    if (daily.plannedTrade == false) {
      unawaited(markDailyPlannedTrade());
    }
    if (!daily.cleanStop) {
      unawaited(markDailyCleanStop());
    }
    unawaited(_persist());
    pendingJuice = pnl >= 0 ? 'win' : 'loss';
    unawaited(DeskAudio.instance.play(pnl >= 0 ? DeskSfx.win : DeskSfx.tap));
    notifyListeners();
    return trade;
  }

  Future<void> completeFirstGesture({bool queueCeremonies = true}) async {
    firstGestureDone = true;
    tutorialTrade = false;
    tutorialStopSet = false;
    firstRunHintDone = true;
    if (beginnerPathStep < 5) {
      beginnerPathStep = 5;
      await _prefs?.setInt('beginnerPathStep', 5);
    }
    await _prefs?.setBool('firstGesture', true);
    await _prefs?.setBool('firstRunHint', true);
    await _prefs?.setBool('tutorialTrade', false);
    Analytics.log('mission_4_journal');
    Analytics.log('first_win');
    Analytics.log('daily_desk_unlock');
    if (queueCeremonies) {
      if (!firstWinCeremonySeen) pendingFirstWinCeremony = true;
      _queueCommunityGateIfNeeded();
    }
    notifyListeners();
  }

  ClosedTrade? _closeTutorial(Position pos, double? exitOverride) {
    final exit = exitOverride ?? _markFor(pos.symbol);
    final fee = exit * pos.qty * MarketFeed.feeRate;
    final gross = pos.side == Side.long
        ? (exit - pos.entry) * pos.qty
        : (pos.entry - exit) * pos.qty;
    final pnl = gross - fee;
    cash += pos.qty * pos.entry + gross - fee;
    final snap = _buildTapeSnapshot(pos, exit);
    final trade = ClosedTrade(
      id: pos.id,
      symbol: pos.symbol,
      side: pos.side,
      qty: pos.qty,
      entry: pos.entry,
      exit: exit,
      pnl: pnl,
      rMultiple: pos.rMultiple(exit),
      openedAt: pos.openedAt,
      closedAt: DateTime.now(),
      flags: const {RecapFlag.stopSet, RecapFlag.sizeOk, RecapFlag.noWiden, RecapFlag.noRevenge},
      scoreDelta: 8,
      tip: 'First trade protected. That is the desk process.',
      stop: pos.stop,
      tp: pos.tp,
      mfe: snap.mfe,
      mae: snap.mae,
      exitKind: TradeExitKind.manual,
      tape: snap.tape,
      entryIndex: snap.entryIndex,
      exitIndex: snap.exitIndex,
    );
    history.insert(0, trade);
    lastTutorialTrade = trade;
    pendingShareRitual = null;
    position = null;
    unawaited(_persist());
    pendingJuice = 'win';
    unawaited(DeskAudio.instance.play(DeskSfx.win));
    notifyListeners();
    return trade;
  }

  Future<void> markFirstWinCeremonySeen() async {
    firstWinCeremonySeen = true;
    pendingFirstWinCeremony = false;
    await _prefs?.setBool('firstWinCeremonySeen', true);
    notifyListeners();
  }

  Future<void> markSoftAuthPromptSeen() async {
    softAuthPromptSeen = true;
    await _prefs?.setBool('softAuthPromptSeen', true);
    notifyListeners();
  }

  void _queueCommunityGateIfNeeded() {
    if (beginnerPathStep < 5 || communityGateAccepted) {
      pendingCommunityGate = false;
      return;
    }
    final streak = meta.loginStreak;
    // Day-3 gate only after the user has copied the move at least twice.
    final ready = move1Copies >= 2;
    final canShow = ready &&
        ((!communityGateShown && streak >= 3) ||
            (communityGateDismissed && !communityGateAccepted && streak >= 7));
    pendingCommunityGate = canShow;
  }

  Future<void> markCommunityGateShown() async {
    communityGateShown = true;
    pendingCommunityGate = false;
    await _prefs?.setBool('communityGateShown', true);
    Analytics.log('community_gate_shown');
    notifyListeners();
  }

  Future<void> acceptCommunityGate() async {
    communityGateAccepted = true;
    communityGateDismissed = false;
    communityGateShown = true;
    pendingCommunityGate = false;
    await _prefs?.setBool('communityGateAccepted', true);
    await _prefs?.setBool('communityGateDismissed', false);
    await _prefs?.setBool('communityGateShown', true);
    Analytics.log('community_gate_accept');
    Analytics.log('tg_cta_tap', {
      'source': AppLinks.communitySource,
      'gate': 'day3',
      'url': AppLinks.communityUrl,
    });
    notifyListeners();
  }

  Future<void> dismissCommunityGate() async {
    communityGateDismissed = true;
    communityGateShown = true;
    pendingCommunityGate = false;
    await _prefs?.setBool('communityGateDismissed', true);
    await _prefs?.setBool('communityGateShown', true);
    Analytics.log('community_gate_dismiss');
    notifyListeners();
  }

  ClosedTrade? closePosition({double? exitOverride, TradeExitKind? kind}) {
    final pos = position;
    if (pos == null) return null;
    if (tutorialTrade) {
      return _closeTutorial(pos, exitOverride);
    }
    if (moveCopyTrade) {
      return _closeMoveCopy(pos, exitOverride);
    }
    final exit = exitOverride ?? _markFor(pos.symbol);
    final exitKind = kind ?? TradeExitKind.manual;
    final gross = pos.side == Side.long
        ? (exit - pos.entry) * pos.qty
        : (pos.entry - exit) * pos.qty;
    final fee = exit * pos.qty * MarketFeed.feeRate;
    final pnl = gross - fee;
    cash += pos.qty * pos.entry + gross - fee;

    final accountBase = max(cash - pnl, 1.0);
    final flags = <RecapFlag>{
      RecapFlag.stopSet,
      if (pos.riskAmount() / accountBase <= 0.05) RecapFlag.sizeOk,
      if (!_widenedStop) RecapFlag.noWiden,
    };

    var revenge = false;
    if (_lastLossAt != null &&
        DateTime.now().difference(_lastLossAt!) < const Duration(minutes: 10) &&
        _tradesLast10Min >= 3) {
      revenge = true;
    } else {
      flags.add(RecapFlag.noRevenge);
    }

    var delta = 0;
    if (flags.contains(RecapFlag.stopSet)) delta += 2;
    if (flags.contains(RecapFlag.sizeOk)) delta += 3;
    if (flags.contains(RecapFlag.noWiden)) delta += 3;
    if (flags.contains(RecapFlag.noRevenge)) delta += 2;
    if (_widenedStop) delta -= 6;
    if (revenge) delta -= 8;
    if (pnl < 0) _lastLossAt = DateTime.now();
    discipline = (discipline + delta).clamp(0, 100);

    final tip = _widenedStop
        ? 'Don’t widen stops after entry. Cut size instead.'
        : revenge
            ? 'Revenge burst detected. Pause ten minutes.'
            : pnl >= 0
                ? 'Clean book. Repeat the process, not the dopamine.'
                : 'Rules held. Discipline compounds even on red trades.';

    final snap = _buildTapeSnapshot(pos, exit);
    final trade = ClosedTrade(
      id: pos.id,
      symbol: pos.symbol,
      side: pos.side,
      qty: pos.qty,
      entry: pos.entry,
      exit: exit,
      pnl: pnl,
      rMultiple: pos.rMultiple(exit),
      openedAt: pos.openedAt,
      closedAt: DateTime.now(),
      flags: flags,
      scoreDelta: delta,
      tip: tip,
      stop: pos.initialStop,
      tp: pos.tp,
      mfe: snap.mfe,
      mae: snap.mae,
      exitKind: exitKind,
      tape: snap.tape,
      entryIndex: snap.entryIndex,
      exitIndex: snap.exitIndex,
      widenedStop: _widenedStop,
    );

    history.insert(0, trade);
    lastRecap = trade;
    position = null;
    _updateDrawdown();
    if (!_widenedStop && flags.contains(RecapFlag.stopSet)) {
      unawaited(markDailyCleanStop());
      _grantCredits(8, reason: 'clean_stop');
      _grantSeasonXp(12, reason: 'clean_stop');
      _bumpWeekly('stops');
      _bumpWeekly('trades');
    } else {
      _bumpWeekly('trades');
      _grantSeasonXp(4, reason: 'trade_close');
    }
    // Share ritual when process was clean enough.
    if (delta >= 6 || (flags.length >= 3 && !_widenedStop)) {
      pendingShareRitual = trade;
    }
    _checkAchievements(justClosed: trade);
    unawaited(noteSeasonRank(yourRank));
    _syncSeasonRewards();
    _publishLeagueBoard();
    unawaited(syncLeagueScore(force: true));
    Analytics.log('trade_close', {'r': trade.rMultiple, 'delta': delta, 'kind': exitKind.name});
    unawaited(_persist());
    pendingJuice = exitKind == TradeExitKind.stop
        ? 'stop'
        : exitKind == TradeExitKind.tp
            ? 'tp'
            : (pnl >= 0 ? 'win' : 'loss');
    unawaited(DeskAudio.instance.play(pnl >= 0 ? DeskSfx.win : DeskSfx.loss));
    notifyListeners();
    return trade;
  }

  ({List<Candle> tape, int entryIndex, int exitIndex, double mfe, double mae}) _buildTapeSnapshot(
    Position pos,
    double exitPrice,
  ) {
    final book = books[pos.symbol] ?? const <Candle>[];
    if (book.isEmpty) {
      return (tape: const [], entryIndex: 0, exitIndex: 0, mfe: 0, mae: 0);
    }

    // Resolve entry bar by time + price (abs index drifts when tape trims).
    var absEntry = pos.entryAbsIndex.clamp(0, book.length - 1);
    var best = double.infinity;
    for (var i = 0; i < book.length; i++) {
      final c = book[i];
      final mins = (c.openTime.difference(pos.openedAt).inMilliseconds.abs()) / 60000.0;
      final px = (c.close - pos.entry).abs() / max(pos.entry, 1e-9);
      final score = mins + px * 80;
      if (score < best) {
        best = score;
        absEntry = i;
      }
    }

    final absExit = book.length - 1;
    // Keep the whole trade path readable: context before + path + small tail.
    final pre = min(10, absEntry);
    final start = max(0, absEntry - pre);
    final end = min(book.length, absExit + 2);
    // Cap width so chart stays legible (~36 bars).
    var s = start;
    var e = end;
    if (e - s > 36) {
      s = max(0, absEntry - 8);
      e = min(book.length, max(absEntry + 1, absExit) + 1);
      if (e - s > 36) e = s + 36;
    }

    final tape = List<Candle>.from(book.sublist(s, e));
    final entryIndex = (absEntry - s).clamp(0, tape.length - 1);
    final exitIndex = (absExit - s).clamp(0, tape.length - 1);

    // Recompute MFE/MAE from the actual path (includes exit) — live track can drift.
    var mfe = 0.0;
    var mae = 0.0;
    void absorb(double high, double low) {
      if (pos.side == Side.long) {
        mfe = max(mfe, high - pos.entry);
        mae = max(mae, pos.entry - low);
      } else {
        mfe = max(mfe, pos.entry - low);
        mae = max(mae, high - pos.entry);
      }
    }

    for (var i = entryIndex; i <= exitIndex; i++) {
      absorb(tape[i].high, tape[i].low);
    }
    absorb(exitPrice, exitPrice);
    // Live values as floor in case path missed a wick.
    mfe = max(mfe, pos.mfe);
    mae = max(mae, pos.mae);

    return (tape: tape, entryIndex: entryIndex, exitIndex: exitIndex, mfe: mfe, mae: mae);
  }

  Future<void> resetAccount() async {
    position = null;
    history.clear();
    lastRecap = null;
    cash = startingCash;
    peakEquity = startingCash;
    maxDrawdown = 0;
    discipline = 0;
    firstGestureDone = false;
    tutorialTrade = false;
    tutorialStopSet = false;
    beginnerPathStep = 0;
    tutorialRiskPct = 0.01;
    lastTutorialTrade = null;
    communityGateShown = false;
    communityGateAccepted = false;
    communityGateDismissed = false;
    firstWinCeremonySeen = false;
    softAuthPromptSeen = false;
    orientStep = 0;
    phase2BridgeSeen = false;
    phase3BridgeSeen = false;
    phase3Step = 0;
    pendingShellTab = null;
    leagueIntroSeen = false;
    glossarySeen = false;
    phase4BridgeSeen = false;
    phase5BridgeSeen = false;
    phase6BridgeSeen = false;
    shortTeachDone = false;
    teachIsShort = false;
    move1ReplaySeen = false;
    move1Copies = 0;
    habitDesksDone = 0;
    habitViewDay = 1;
    moveCopyTrade = false;
    todaySessionActive = false;
    pendingFirstWinCeremony = false;
    pendingCommunityGate = false;
    meta = DeskMeta();
    daily = DailyDeskState.empty(DateTime.now().toUtc());
    equityCurve
      ..clear()
      ..add(startingCash);
    await _persist();
    await _persistMeta();
    await _persistDaily();
    await _prefs?.remove('qaPresetApplied');
    unawaited(syncLeagueScore(force: true));
    notifyListeners();
  }

  /// Open Desk Club invite (or queue the gate). Used by Today hub card.
  Future<void> openDeskClubInvite() async {
    if (communityGateAccepted) {
      Analytics.log('tg_cta_tap', {'source': 'today_hub', 'gate': 'accepted'});
      notifyListeners();
      return;
    }
    if (!deskClubReady) {
      notifyListeners();
      return;
    }
    pendingCommunityGate = true;
    Analytics.log('desk_club_tap');
    notifyListeners();
  }

  Future<void> applyPlaybook(Playbook pb) async {
    final levels = resolvePlaybook(pb, mark: mark, atrPct: atrPct);
    activePlaybookLevels = levels;
    playbookSeedToken++;
    DeskAudio.instance.play(DeskSfx.tap);
    notifyListeners();
  }

  void clearPlaybookLevels() {
    activePlaybookLevels = null;
    playbookSeedToken++;
    notifyListeners();
  }

  Future<void> savePlaybooks() async {
    await _prefs?.setString('playbooksJson', Playbook.encodeList(playbooks));
  }

  Future<void> upsertPlaybook(Playbook pb) async {
    final i = playbooks.indexWhere((e) => e.id == pb.id);
    if (i >= 0) {
      playbooks[i] = pb;
    } else {
      playbooks = [...playbooks, pb];
    }
    await savePlaybooks();
    notifyListeners();
  }

  Future<void> removePlaybook(String id) async {
    playbooks = playbooks.where((e) => e.id != id).toList();
    await savePlaybooks();
    notifyListeners();
  }

  Future<void> recordTapeDrill(int processScore) async {
    tapeDrillPoints += processScore;
    discipline = (discipline + (processScore >= 4 ? 1 : 0)).clamp(0, 100);
    await _prefs?.setInt('tapeDrillPts', tapeDrillPoints);
    await _prefs?.setInt('discipline', discipline);
    await markDailyDrill();
    _grantCredits(5 + (processScore >= 4 ? 5 : 0), reason: 'tape_drill');
    _grantSeasonXp(10 + processScore, reason: 'tape_drill');
    _bumpWeekly('drills');
    _syncSeasonRewards();
    unawaited(syncLeagueScore());
    notifyListeners();
  }

  Future<void> noteSeasonRank(int rank) async {
    if (rank > 0 && rank < seasonBestRank) {
      seasonBestRank = rank;
      await _prefs?.setInt('seasonBestRank', seasonBestRank);
      _syncSeasonRewards();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _leagueTimer?.cancel();
    _remoteBoardSub?.cancel();
    unawaited(_feed.liveTape.disconnect());
    super.dispose();
  }
}

extension _TakeLast<E> on List<E> {
  Iterable<E> takeLast(int n) => length <= n ? this : sublist(length - n);
}
