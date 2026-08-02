import 'package:paper_league/domain/league_remote.dart';

class Candle {
  const Candle({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  bool get isBull => close >= open;

  Candle copyWith({
    DateTime? openTime,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
  }) {
    return Candle(
      openTime: openTime ?? this.openTime,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() => {
        't': openTime.millisecondsSinceEpoch,
        'o': open,
        'h': high,
        'l': low,
        'c': close,
        'v': volume,
      };

  factory Candle.fromJson(Map<String, dynamic> m) => Candle(
        openTime: DateTime.fromMillisecondsSinceEpoch(m['t'] as int),
        open: (m['o'] as num).toDouble(),
        high: (m['h'] as num).toDouble(),
        low: (m['l'] as num).toDouble(),
        close: (m['c'] as num).toDouble(),
        volume: (m['v'] as num).toDouble(),
      );
}

enum Side { long, short }

enum RecapFlag { stopSet, sizeOk, noWiden, noRevenge }

enum TradeExitKind { stop, tp, manual, partial }

class Position {
  Position({
    required this.id,
    required this.symbol,
    required this.side,
    required this.qty,
    required this.entry,
    required this.openedAt,
    required this.stop,
    this.tp,
    double? initialStop,
    this.mfe = 0,
    this.mae = 0,
    this.entryAbsIndex = 0,
  }) : initialStop = initialStop ?? stop;

  final String id;
  final String symbol;
  final Side side;
  final double qty;
  final double entry;
  final DateTime openedAt;
  double stop;
  double? tp;
  final double initialStop;
  /// Max favorable excursion in price units.
  double mfe;
  /// Max adverse excursion in price units.
  double mae;
  /// Absolute candle index in the book at entry (adjusted when tape trims).
  int entryAbsIndex;

  double notional(double mark) => qty * mark;

  double unrealized(double mark) {
    final diff = side == Side.long ? mark - entry : entry - mark;
    return diff * qty;
  }

  double riskAmount() {
    final dist = (entry - initialStop).abs();
    return dist * qty;
  }

  double rMultiple(double exit) {
    final risk = riskAmount();
    if (risk <= 0) return 0;
    final pnl = side == Side.long ? (exit - entry) * qty : (entry - exit) * qty;
    return pnl / risk;
  }

  bool hitStop(double high, double low) {
    if (side == Side.long) return low <= stop;
    return high >= stop;
  }

  bool hitTp(double high, double low) {
    final target = tp;
    if (target == null) return false;
    if (side == Side.long) return high >= target;
    return low <= target;
  }

  void trackExcursion(Candle c) {
    if (side == Side.long) {
      final fav = c.high - entry;
      final adv = entry - c.low;
      if (fav > mfe) mfe = fav;
      if (adv > mae) mae = adv;
    } else {
      final fav = entry - c.low;
      final adv = c.high - entry;
      if (fav > mfe) mfe = fav;
      if (adv > mae) mae = adv;
    }
  }
}

class ClosedTrade {
  const ClosedTrade({
    required this.id,
    required this.symbol,
    required this.side,
    required this.qty,
    required this.entry,
    required this.exit,
    required this.pnl,
    required this.rMultiple,
    required this.openedAt,
    required this.closedAt,
    required this.flags,
    required this.scoreDelta,
    required this.tip,
    this.stop,
    this.tp,
    this.mfe = 0,
    this.mae = 0,
    this.exitKind = TradeExitKind.manual,
    this.tape = const [],
    this.entryIndex = 0,
    this.exitIndex = 0,
    this.widenedStop = false,
  });

  final String id;
  final String symbol;
  final Side side;
  final double qty;
  final double entry;
  final double exit;
  final double pnl;
  final double rMultiple;
  final DateTime openedAt;
  final DateTime closedAt;
  final Set<RecapFlag> flags;
  final int scoreDelta;
  final String tip;
  final double? stop;
  final double? tp;
  final double mfe;
  final double mae;
  final TradeExitKind exitKind;
  final List<Candle> tape;
  final int entryIndex;
  final int exitIndex;
  final bool widenedStop;
}

class LeagueEntry {
  const LeagueEntry({
    required this.name,
    required this.score,
    required this.discipline,
    required this.maxDd,
    required this.retPct,
    this.isYou = false,
    this.hue = 188,
    this.streak = 0,
    this.discPart = 0,
    this.ddPart = 0,
    this.retPart = 0,
    this.rankDelta = 0,
    this.scoreDelta = 0,
    this.division = LeagueDivision.rookie,
    this.remote = false,
    this.userId,
  });

  final String name;
  final double score;
  final double discipline;
  final double maxDd;
  final double retPct;
  final bool isYou;
  final int hue;
  final int streak;
  /// Weighted components that sum ≈ score (for UI bars).
  final double discPart;
  final double ddPart;
  final double retPart;
  /// Positive = climbed places since last pulse.
  final int rankDelta;
  final double scoreDelta;
  final LeagueDivision division;
  final bool remote;
  final String? userId;

  LeagueEntry copyWith({
    String? name,
    double? score,
    double? discipline,
    double? maxDd,
    double? retPct,
    bool? isYou,
    int? hue,
    int? streak,
    double? discPart,
    double? ddPart,
    double? retPart,
    int? rankDelta,
    double? scoreDelta,
    LeagueDivision? division,
    bool? remote,
    String? userId,
  }) {
    return LeagueEntry(
      name: name ?? this.name,
      score: score ?? this.score,
      discipline: discipline ?? this.discipline,
      maxDd: maxDd ?? this.maxDd,
      retPct: retPct ?? this.retPct,
      isYou: isYou ?? this.isYou,
      hue: hue ?? this.hue,
      streak: streak ?? this.streak,
      discPart: discPart ?? this.discPart,
      ddPart: ddPart ?? this.ddPart,
      retPart: retPart ?? this.retPart,
      rankDelta: rankDelta ?? this.rankDelta,
      scoreDelta: scoreDelta ?? this.scoreDelta,
      division: division ?? this.division,
      remote: remote ?? this.remote,
      userId: userId ?? this.userId,
    );
  }
}
