import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/domain/season_liveops.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';

/// Compact season pressure + track claim on League / Daily.
class SeasonLiveCard extends StatelessWidget {
  const SeasonLiveCard({super.key});

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    final season = desk.season;
    final sp = desk.seasonProgress;
    final weeklies = desk.currentWeeklies;
    final todayNode = trackNodeForDay(season.day);
    final canClaim = desk.canClaimTodayTrack;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PlRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            season.phase.name == 'finals'
                ? PlColors.bear.withValues(alpha: 0.18)
                : season.phase.name == 'contest'
                    ? PlColors.warn.withValues(alpha: 0.16)
                    : PlColors.accentDim,
            PlColors.surface,
          ],
        ),
        border: Border.all(color: PlColors.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                s.seasonTrack,
                style: const TextStyle(
                  color: PlColors.accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                'SP ${sp.seasonXp}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desk.seasonPressureFor(s.isRu),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
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
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: buildSeasonTrack().length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final node = buildSeasonTrack()[i];
                final claimed = sp.claimedDay(node.day);
                final locked = node.day > season.day;
                final isToday = node.day == season.day;
                return GestureDetector(
                  onTap: () async {
                    DeskAudio.instance.play(DeskSfx.tap);
                    if (claimed || locked) return;
                    if (isToday) {
                      final ok = await desk.claimTodayTrack();
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.trackNeedActive)),
                        );
                      } else if (ok) {
                        HapticFeedback.mediumImpact();
                      }
                      return;
                    }
                    // Catch-up past day
                    final ok = await desk.claimTrackDay(node.day, catchUp: true);
                    if (!context.mounted) return;
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.trackCatchUpFail)),
                      );
                    } else {
                      HapticFeedback.selectionClick();
                    }
                  },
                  child: Container(
                    width: 44,
                    decoration: BoxDecoration(
                      color: claimed
                          ? PlColors.bullSoft
                          : isToday
                              ? PlColors.accentSoft
                              : PlColors.bgElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: claimed
                            ? PlColors.bull
                            : isToday
                                ? PlColors.accent
                                : PlColors.lineSoft,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'D${node.day}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: locked ? PlColors.faint : PlColors.text,
                          ),
                        ),
                        Icon(
                          claimed
                              ? Icons.check_rounded
                              : locked
                                  ? Icons.lock_outline
                                  : Icons.card_giftcard_rounded,
                          size: 14,
                          color: claimed
                              ? PlColors.bull
                              : isToday
                                  ? PlColors.accent
                                  : PlColors.muted,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (todayNode != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    canClaim
                        ? '${s.trackClaimToday}: ${todayNode.title(s.isRu)}'
                        : sp.claimedDay(season.day)
                            ? s.trackClaimed
                            : todayNode.title(s.isRu),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                if (canClaim)
                  FilledButton(
                    onPressed: () async {
                      DeskAudio.instance.play(DeskSfx.tap);
                      await desk.claimTodayTrack();
                      HapticFeedback.mediumImpact();
                    },
                    child: Text(s.claim),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Text(s.weeklyChallenges, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...weeklies.map((c) {
            final cur = (sp.weeklyProgress[c.id] ?? 0).clamp(0, c.target);
            final done = cur >= c.target;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.title(s.isRu),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: done ? PlColors.bull : PlColors.text,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '$cur/${c.target}',
                        style: TextStyle(
                          color: done ? PlColors.bull : PlColors.muted,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: c.target == 0 ? 0 : cur / c.target,
                      minHeight: 3,
                      backgroundColor: PlColors.surface2,
                      color: done ? PlColors.bull : PlColors.accent,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
