import 'dart:math';

import 'package:paper_league/domain/league_remote.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/domain/season.dart';

class LeagueFeedItem {
  const LeagueFeedItem({
    required this.at,
    required this.name,
    required this.textEn,
    required this.textRu,
    required this.delta,
  });

  final DateTime at;
  final String name;
  final String textEn;
  final String textRu;
  final double delta;

  String text(bool ru) => ru ? textRu : textEn;
}

class SeasonMemory {
  const SeasonMemory({
    required this.number,
    required this.bestRank,
    required this.titleEn,
    required this.titleRu,
  });

  final int number;
  final int bestRank;
  final String titleEn;
  final String titleRu;

  String title(bool ru) => ru ? titleRu : titleEn;
}

/// Mutable rival board that breathes between market ticks.
class LeaguePulse {
  LeaguePulse();

  final Map<String, double> bias = {};
  final Map<String, int> prevRank = {};
  final Map<String, double> prevScore = {};
  final List<LeagueFeedItem> feed = [];
  int generation = 0;

  static const names = [
    ('mara', 198),
    ('diego', 32),
    ('sofia', 312),
    ('kenji', 145),
    ('luna', 265),
    ('orin', 88),
    ('nova', 210),
    ('rex', 12),
    ('aria', 240),
    ('voss', 55),
    ('kira', 170),
    ('jade', 95),
  ];

  List<LeagueEntry> baseRivals(SeasonInfo s) {
    final rng = Random(s.number * 9973 + 17);
    final dayBoost = s.day * 0.12;
    return names.map((n) {
      final baseDd = 1.2 + rng.nextDouble() * 4.5;
      final baseRet =
          -2 + rng.nextDouble() * 9 + (rng.nextBool() ? dayBoost * 0.3 : -dayBoost * 0.15);
      final disc =
          (78 + rng.nextDouble() * 18 + sin(dayBoost + rng.nextDouble()) * 2.2).clamp(70.0, 98.0);
      final riskCtrl = (100 - baseDd * 8).clamp(20.0, 100.0);
      final ret = (50 + baseRet * 4).clamp(20.0, 100.0);
      final score = disc * 0.6 + riskCtrl * 0.25 + ret * 0.15 + (bias[n.$1] ?? 0);
      return LeagueEntry(
        name: n.$1,
        score: score,
        discipline: disc,
        maxDd: baseDd,
        retPct: baseRet,
        hue: n.$2,
        streak: rng.nextInt(6),
        discPart: disc * 0.6,
        ddPart: riskCtrl * 0.25,
        retPart: ret * 0.15,
        division: divisionForScore(score),
      );
    }).toList();
  }

  /// Nudge one rival; return feed line if meaningful.
  LeagueFeedItem? tick(Random rng, SeasonInfo season) {
    generation++;
    final pick = names[rng.nextInt(names.length)].$1;
    final delta = (rng.nextDouble() - 0.42) * 0.55;
    bias[pick] = ((bias[pick] ?? 0) + delta).clamp(-4.5, 5.5);
    if (delta.abs() < 0.12) return null;

    final up = delta > 0;
    final item = LeagueFeedItem(
      at: DateTime.now(),
      name: pick,
      delta: delta,
      textEn: up
          ? '$pick tightened risk · ${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)}'
          : '$pick slipped on widen · ${delta.toStringAsFixed(2)}',
      textRu: up
          ? '$pick подтянул риск · ${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)}'
          : '$pick просел на widen · ${delta.toStringAsFixed(2)}',
    );
    feed.insert(0, item);
    if (feed.length > 16) feed.removeLast();
    return item;
  }

  List<LeagueEntry> withDeltas(List<LeagueEntry> sorted) {
    final out = <LeagueEntry>[];
    for (var i = 0; i < sorted.length; i++) {
      final e = sorted[i];
      final rank = i + 1;
      final oldRank = prevRank[e.name];
      final oldScore = prevScore[e.name];
      final rankDelta = oldRank == null ? 0 : oldRank - rank;
      final scoreDelta = oldScore == null ? 0.0 : e.score - oldScore;
      out.add(e.copyWith(rankDelta: rankDelta, scoreDelta: scoreDelta));
    }
    return out;
  }

  void commitSnapshot(List<LeagueEntry> sorted) {
    for (var i = 0; i < sorted.length; i++) {
      prevRank[sorted[i].name] = i + 1;
      prevScore[sorted[i].name] = sorted[i].score;
    }
  }

  List<SeasonMemory> memories(SeasonInfo current, int bestRankThis) {
    final list = <SeasonMemory>[];
    for (var i = 1; i <= 3; i++) {
      final n = current.number - i;
      if (n < 1) continue;
      final rng = Random(n * 41);
      final rank = 1 + rng.nextInt(8);
      final title = SeasonInfo(
        number: n,
        day: 28,
        startedAt: current.startedAt,
        endsAt: current.endsAt,
        phase: SeasonPhase.finals,
      ).titleForRank(rank, false);
      final titleRu = SeasonInfo(
        number: n,
        day: 28,
        startedAt: current.startedAt,
        endsAt: current.endsAt,
        phase: SeasonPhase.finals,
      ).titleForRank(rank, true);
      list.add(SeasonMemory(
        number: n,
        bestRank: rank,
        titleEn: title,
        titleRu: titleRu,
      ));
    }
    // Current season memory (live)
    list.insert(
      0,
      SeasonMemory(
        number: current.number,
        bestRank: bestRankThis.clamp(1, 99),
        titleEn: current.titleForRank(bestRankThis.clamp(1, 99), false),
        titleRu: current.titleForRank(bestRankThis.clamp(1, 99), true),
      ),
    );
    return list;
  }
}
