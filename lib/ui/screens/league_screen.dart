import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/domain/league_remote.dart';
import 'package:paper_league/domain/league_live.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/domain/season.dart';
import 'package:paper_league/domain/daily_desk.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/auth_controller.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/format.dart';
import 'package:paper_league/ui/screens/tape_drill_screen.dart';
import 'package:paper_league/ui/widgets/pl_chrome.dart';
import 'package:paper_league/ui/widgets/playbooks_sheet.dart';
import 'package:paper_league/ui/widgets/season_ceremony.dart';
import 'package:paper_league/ui/widgets/season_live_card.dart';

class LeagueScreen extends StatefulWidget {
  const LeagueScreen({super.key});

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: PlMotion.emphasis)..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final desk = context.read<DeskController>();
      desk.noteSeasonRank(desk.yourRank);
      await maybeShowSeasonCeremony(
        context,
        season: desk.season,
        lastSeenSeason: desk.lastCeremonySeason,
        bestRank: desk.seasonBestRank,
        onSeen: desk.markCeremonySeen,
        nickname: desk.nickname,
      );
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    final board = desk.leaderboard;
    final season = desk.season;
    final youRank = desk.yourRank;
    final you = board.firstWhere((e) => e.isYou, orElse: () => board.last);
    final top3 = board.take(3).toList();
    final rem = season.remaining;
    final remLabel = rem == Duration.zero
        ? s.chartReset
        : '${rem.inDays}d ${rem.inHours.remainder(24)}h';

    return FadeTransition(
      opacity: CurvedAnimation(parent: _intro, curve: PlMotion.curveIn),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(PlSpace.lg, PlSpace.md, PlSpace.lg, 40),
        children: [
          _SeasonHeader(season: season, remLabel: remLabel, s: s, live: desk.leagueIsLive),
          if (!desk.leagueIsLive)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(s.leagueDemoHint, style: Theme.of(context).textTheme.bodySmall),
            )
          else if (desk.leaderboard.where((e) => e.remote && !e.isYou).isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(s.leagueStartApi, style: Theme.of(context).textTheme.bodySmall),
            ),
          const SizedBox(height: PlSpace.lg),
          const SeasonLiveCard(),
          const SizedBox(height: PlSpace.lg),
          _YouHero(
            desk: desk,
            you: you,
            rank: youRank,
            season: season,
            s: s,
          ),
          const SizedBox(height: PlSpace.lg),
          _ScoreBreakdown(you: you, s: s),
          const SizedBox(height: PlSpace.xl),
          PlSectionTitle(s.liveFeed, trailing: _LiveDot()),
          const SizedBox(height: PlSpace.md),
          _LiveFeed(feed: desk.leagueFeed, ru: s.isRu),
          const SizedBox(height: PlSpace.xl),
          PlSectionTitle(s.podium),
          const SizedBox(height: PlSpace.md),
          _Podium(top: top3, season: season, s: s),
          const SizedBox(height: PlSpace.xl),
          PlSectionTitle(
            s.standings,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.leagueRulesShort, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(width: 8),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    DeskAudio.instance.play(DeskSfx.tap);
                    final auth = context.read<AuthController>();
                    final live = auth.onlineConfigured && auth.isSignedIn;
                    final repo = auth.league;
                    await desk.syncLeagueScore(force: true);
                    if (!context.mounted) return;
                    await desk.bindOnline(repo, live: live);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: PlColors.accent),
                  tooltip: s.leagueRetry,
                ),
              ],
            ),
          ),
          const SizedBox(height: PlSpace.md),
          ...board.asMap().entries.map((e) {
            final rank = e.key + 1;
            return _StandingRow(
              rank: rank,
              entry: e.value,
              title: season.titleForRank(rank, s.isRu),
              delayMs: e.key * 22,
            );
          }),
          const SizedBox(height: PlSpace.xl),
          PlSectionTitle(s.seasonHistory),
          const SizedBox(height: PlSpace.md),
          _SeasonHistory(
            items: desk.seasonMemories,
            remote: desk.remoteTitles,
            ru: s.isRu,
          ),
          const SizedBox(height: PlSpace.xl),
          PlSectionTitle(s.seasonRewards),
          const SizedBox(height: PlSpace.md),
          _SeasonRewards(rewards: desk.seasonRewards, ru: s.isRu),
          const SizedBox(height: PlSpace.xl),
          PlSectionTitle(s.training),
          const SizedBox(height: PlSpace.md),
          Row(
            children: [
              Expanded(
                child: _TrainCard(
                  icon: Icons.slow_motion_video_rounded,
                  title: s.tapeDrill,
                  sub: s.tapeDrillSub,
                  onTap: () {
                    DeskAudio.instance.play(DeskSfx.tap);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const TapeDrillScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TrainCard(
                  icon: Icons.bookmark_added_outlined,
                  title: s.playbooks,
                  sub: s.playbooksSub,
                  onTap: () {
                    DeskAudio.instance.play(DeskSfx.tap);
                    showPlaybooksSheet(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeasonHeader extends StatelessWidget {
  const _SeasonHeader({
    required this.season,
    required this.remLabel,
    required this.s,
    required this.live,
  });
  final SeasonInfo season;
  final String remLabel;
  final S s;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PlSpace.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PlRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlColors.accentDim,
            PlColors.surface,
            PlColors.bgElevated,
          ],
        ),
        border: Border.all(color: PlColors.accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PlColors.accentSoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: PlColors.accent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${s.season} ${season.number}',
                  style: const TextStyle(
                    color: PlColors.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: live ? PlColors.bullSoft : PlColors.surface2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (live ? PlColors.bull : PlColors.warn).withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  live ? s.leagueLive : s.leagueDemo,
                  style: TextStyle(
                    color: live ? PlColors.bull : PlColors.warn,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${season.phaseLabel(s.isRu)} · ${s.day} ${season.day}/28',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                remLabel,
                style: const TextStyle(
                  color: PlColors.accent,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: season.progress,
              minHeight: 4,
              backgroundColor: PlColors.surface2,
              color: PlColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(s.seasonHint, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _YouHero extends StatelessWidget {
  const _YouHero({
    required this.desk,
    required this.you,
    required this.rank,
    required this.season,
    required this.s,
  });

  final DeskController desk;
  final LeagueEntry you;
  final int rank;
  final SeasonInfo season;
  final S s;

  @override
  Widget build(BuildContext context) {
    final title = season.titleForRank(rank, s.isRu);
    return Container(
      padding: const EdgeInsets.all(PlSpace.lg),
      decoration: BoxDecoration(
        color: PlColors.surface,
        borderRadius: BorderRadius.circular(PlRadius.lg),
        border: Border.all(color: PlColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              PlAvatar(
                nickname: desk.nickname,
                hue: desk.avatarHue,
                path: desk.avatarPath,
                size: 64,
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: PlColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: PlColors.onAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${you.division.label(s.isRu).toUpperCase()} · ${title.toUpperCase()}',
                  style: const TextStyle(
                    color: PlColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  you.score.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 40,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${desk.nickname} · ${s.disc} ${desk.discipline}'
                  '${you.streak > 0 ? ' · ${you.streak} ${s.streakLabel}' : ''}'
                  '${you.rankDelta != 0 ? ' · ${you.rankDelta > 0 ? '↑' : '↓'}${you.rankDelta.abs()}' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({required this.you, required this.s});
  final LeagueEntry you;
  final S s;

  @override
  Widget build(BuildContext context) {
    final total = (you.discPart + you.ddPart + you.retPart).clamp(1.0, 999.0);
    Widget bar(String label, double part, Color color, String hint) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const Spacer(),
                Text(
                  part.toStringAsFixed(1),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: (part / total).clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: PlColors.surface2,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(hint, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
          ],
        ),
      );
    }

    return Row(
      children: [
        bar(s.disc, you.discPart, PlColors.accent, '60%'),
        const SizedBox(width: 10),
        bar(s.maxDd, you.ddPart, PlColors.warn, '25%'),
        const SizedBox(width: 10),
        bar(s.session, you.retPart, PlColors.bull, '15%'),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top, required this.season, required this.s});
  final List<LeagueEntry> top;
  final SeasonInfo season;
  final S s;

  @override
  Widget build(BuildContext context) {
    LeagueEntry? at(int i) => i < top.length ? top[i] : null;
    final second = at(1);
    final first = at(0);
    final third = at(2);

    return SizedBox(
      height: 168,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodSlot(rank: 2, entry: second, height: 110, season: season, s: s)),
          const SizedBox(width: 8),
          Expanded(child: _PodSlot(rank: 1, entry: first, height: 148, season: season, s: s, crown: true)),
          const SizedBox(width: 8),
          Expanded(child: _PodSlot(rank: 3, entry: third, height: 92, season: season, s: s)),
        ],
      ),
    );
  }
}

class _PodSlot extends StatelessWidget {
  const _PodSlot({
    required this.rank,
    required this.entry,
    required this.height,
    required this.season,
    required this.s,
    this.crown = false,
  });

  final int rank;
  final LeagueEntry? entry;
  final double height;
  final SeasonInfo season;
  final S s;
  final bool crown;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final accent = rank == 1
        ? PlColors.accent
        : rank == 2
            ? PlColors.muted
            : PlColors.warn;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (e != null) ...[
          if (crown) const Icon(Icons.workspace_premium_rounded, color: PlColors.accent, size: 22),
          PlAvatar(nickname: e.name, hue: e.hue, size: crown ? 44 : 36),
          const SizedBox(height: 6),
          Text(
            e.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: e.isYou ? PlColors.accent : PlColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            e.score.toStringAsFixed(1),
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accent.withValues(alpha: 0.35),
                PlColors.surface2,
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            '#$rank',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.rank,
    required this.entry,
    required this.title,
    required this.delayMs,
  });

  final int rank;
  final LeagueEntry entry;
  final String title;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // Static row — avoid re-tweening on every desk tick rebuild.
    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: entry.isYou ? PlColors.accentSoft.withValues(alpha: 0.55) : PlColors.surface,
          borderRadius: BorderRadius.circular(PlRadius.md),
          border: Border.all(
            color: entry.isYou ? PlColors.accent.withValues(alpha: 0.45) : PlColors.lineSoft,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: PlColors.faint,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            PlAvatar(nickname: entry.name, hue: entry.hue, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: TextStyle(
                      fontWeight: entry.isYou ? FontWeight.w800 : FontWeight.w600,
                      color: PlColors.text,
                    ),
                  ),
                  Text(
                    '$title · ${entry.division.label(s.isRu)} · DD ${entry.maxDd.toStringAsFixed(1)}% · ${pctPoints(entry.retPct)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.score.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (entry.rankDelta != 0)
                      Text(
                        '${entry.rankDelta > 0 ? '↑' : '↓'}${entry.rankDelta.abs()}',
                        style: TextStyle(
                          color: entry.rankDelta > 0 ? PlColors.bull : PlColors.bear,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (entry.rankDelta != 0) const SizedBox(width: 4),
                    Text(
                      entry.scoreDelta == 0
                          ? 'D ${entry.discipline.toStringAsFixed(0)}'
                          : '${entry.scoreDelta >= 0 ? '+' : ''}${entry.scoreDelta.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: entry.scoreDelta > 0
                            ? PlColors.bull
                            : entry.scoreDelta < 0
                                ? PlColors.bear
                                : PlColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(color: PlColors.bull, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(S.of(context).live, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: PlColors.bull)),
      ],
    );
  }
}

class _LiveFeed extends StatelessWidget {
  const _LiveFeed({required this.feed, required this.ru});
  final List<LeagueFeedItem> feed;
  final bool ru;

  @override
  Widget build(BuildContext context) {
    if (feed.isEmpty) {
      return PlSurface(
        gradient: true,
        padding: const EdgeInsets.all(14),
        child: Text(
          ru ? 'Пульс лиги сейчас тихий — скоро появится движение.' : 'League pulse is quiet — movement incoming.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: feed.length.clamp(0, 8),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = feed[i];
          final up = f.delta >= 0;
          return Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PlColors.surface,
              borderRadius: BorderRadius.circular(PlRadius.md),
              border: Border.all(color: PlColors.lineSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      f.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${up ? '+' : ''}${f.delta.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: up ? PlColors.bull : PlColors.bear,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  f.text(ru),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SeasonHistory extends StatelessWidget {
  const _SeasonHistory({required this.items, required this.ru, this.remote = const []});
  final List<SeasonMemory> items;
  final List<SeasonTitleRow> remote;
  final bool ru;

  @override
  Widget build(BuildContext context) {
    // Prefer remote titles grouped by season when available.
    final bySeason = <int, List<SeasonTitleRow>>{};
    for (final t in remote) {
      bySeason.putIfAbsent(t.seasonNumber, () => []).add(t);
    }
    final seasons = bySeason.keys.toList()..sort((a, b) => b.compareTo(a));

    if (seasons.isNotEmpty) {
      return SizedBox(
        height: 78,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: seasons.length.clamp(0, 6),
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final n = seasons[i];
            final top = bySeason[n]!.first;
            final live = i == 0;
            return Container(
              width: 148,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PlRadius.md),
                gradient: LinearGradient(
                  colors: live
                      ? [PlColors.accentDim, PlColors.surface]
                      : [PlColors.surface, PlColors.bgElevated],
                ),
                border: Border.all(
                  color: live ? PlColors.accent.withValues(alpha: 0.4) : PlColors.lineSoft,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'S$n',
                    style: TextStyle(
                      color: live ? PlColors.accent : PlColors.faint,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Text('#${top.rank}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  Text(
                    top.nickname ?? top.title(ru),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final m = items[i];
          final live = i == 0;
          return Container(
            width: 148,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PlRadius.md),
              gradient: LinearGradient(
                colors: live
                    ? [PlColors.accentDim, PlColors.surface]
                    : [PlColors.surface, PlColors.bgElevated],
              ),
              border: Border.all(
                color: live ? PlColors.accent.withValues(alpha: 0.4) : PlColors.lineSoft,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  live ? (ru ? 'СЕЙЧАС' : 'NOW') : 'S${m.number}',
                  style: TextStyle(
                    color: live ? PlColors.accent : PlColors.faint,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Text('#${m.bestRank}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text(m.title(ru), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SeasonRewards extends StatelessWidget {
  const _SeasonRewards({required this.rewards, required this.ru});
  final List<SeasonReward> rewards;
  final bool ru;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rewards.map((r) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: r.unlocked ? PlColors.accentSoft.withValues(alpha: 0.55) : PlColors.surface,
            borderRadius: BorderRadius.circular(PlRadius.md),
            border: Border.all(
              color: r.unlocked ? PlColors.accent.withValues(alpha: 0.4) : PlColors.lineSoft,
            ),
          ),
          child: Row(
            children: [
              Icon(
                r.unlocked ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
                color: r.unlocked ? PlColors.accent : PlColors.faint,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title(ru), style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(r.hint(ru), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TrainCard extends StatelessWidget {
  const _TrainCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PlColors.surface,
      borderRadius: BorderRadius.circular(PlRadius.md),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(PlRadius.md),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PlRadius.md),
            border: Border.all(color: PlColors.lineSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: PlColors.accent, size: 22),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 4),
              Text(sub, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
