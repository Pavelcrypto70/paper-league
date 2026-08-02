import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/domain/season.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/analytics.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:share_plus/share_plus.dart';

Future<void> maybeShowSeasonCeremony(
  BuildContext context, {
  required SeasonInfo season,
  required int? lastSeenSeason,
  required Future<void> Function(int seasonNumber) onSeen,
  required int bestRank,
  required String nickname,
}) async {
  if (lastSeenSeason == season.number) return;

  final s = S.of(context);
  DeskAudio.instance.play(DeskSfx.win);
  HapticFeedback.heavyImpact();
  Analytics.log('season_ceremony_seen', {'season': season.number});

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.92, end: 1),
        duration: PlMotion.emphasis,
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: AlertDialog(
        backgroundColor: PlColors.surface,
        title: Text(
          season.phase == SeasonPhase.finals ? s.finalsPulse : s.ceremonyTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${s.season} ${season.number} · ${season.phaseLabel(s.isRu)} · ${s.day} ${season.day}/28',
              style: const TextStyle(color: PlColors.accent, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(s.ceremonyBody),
            if (bestRank < 99) ...[
              const SizedBox(height: 10),
              Text(
                '${s.rank} #$bestRank · ${season.titleForRank(bestRank, s.isRu)}',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final title = season.titleForRank(bestRank.clamp(1, 99), s.isRu);
              final text = s.isRu
                  ? 'Paper League · Сезон ${season.number}\n$nickname · ${s.rank} #$bestRank · $title\n${s.shareTagline}'
                  : 'Paper League · Season ${season.number}\n$nickname · ${s.rank} #$bestRank · $title\n${s.shareTagline}';
              await SharePlus.instance.share(ShareParams(text: text));
              HapticFeedback.mediumImpact();
            },
            child: Text(s.shareRecap),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.ceremonyGo),
          ),
        ],
      ),
      );
    },
  );
  await onSeen(season.number);
}
