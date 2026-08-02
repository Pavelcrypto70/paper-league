import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/domain/achievements.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/theme/tokens.dart';

Future<void> showAchievementToasts(BuildContext context, List<String> keys) async {
  if (keys.isEmpty || !context.mounted) return;
  for (final key in keys) {
    final def = achievementByKey(key);
    if (def == null) continue;
    if (!context.mounted) return;
    await _showOne(context, def);
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }
}

Future<void> _showOne(BuildContext context, AchievementDef def) async {
  final s = S.of(context);
  HapticFeedback.mediumImpact();
  DeskAudio.instance.play(DeskSfx.win);

  final entry = OverlayEntry(
    builder: (ctx) => _AchievementBanner(
      title: def.title(s.isRu),
      subtitle: def.desc(s.isRu),
      icon: def.icon,
      badge: s.achievementUnlocked,
    ),
  );

  final overlay = Overlay.of(context);
  overlay.insert(entry);
  await Future<void>.delayed(const Duration(milliseconds: 2400));
  entry.remove();
}

class _AchievementBanner extends StatefulWidget {
  const _AchievementBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;

  @override
  State<_AchievementBanner> createState() => _AchievementBannerState();
}

class _AchievementBannerState extends State<_AchievementBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: PlMotion.emphasis)..forward();
    _slide = Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _c, curve: PlMotion.curveIn),
    );
    _fade = CurvedAnimation(parent: _c, curve: PlMotion.curveIn);
    Future<void>.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) _c.reverse();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: PlColors.surface,
                    borderRadius: BorderRadius.circular(PlRadius.md),
                    border: Border.all(color: PlColors.accent.withValues(alpha: 0.45)),
                    boxShadow: [
                      BoxShadow(
                        color: PlColors.accent.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: PlColors.accentSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, color: PlColors.accent, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.badge,
                              style: const TextStyle(
                                color: PlColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: PlColors.text,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              style: const TextStyle(color: PlColors.muted, fontSize: 12, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AchievementsGrid extends StatelessWidget {
  const AchievementsGrid({
    super.key,
    required this.unlocked,
  });

  final Set<String> unlocked;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final done = unlocked.length;
    final total = kAchievements.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(s.achievements, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text(
              '$done / $total',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: PlColors.accent),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(s.achievementsSub, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, box) {
            final cross = box.maxWidth > 420 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kAchievements.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, i) {
                final a = kAchievements[i];
                final on = unlocked.contains(a.key);
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: on ? PlColors.accentSoft.withValues(alpha: 0.55) : PlColors.surface,
                    borderRadius: BorderRadius.circular(PlRadius.md),
                    border: Border.all(
                      color: on ? PlColors.accent.withValues(alpha: 0.4) : PlColors.lineSoft,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        a.icon,
                        size: 22,
                        color: on ? PlColors.accent : PlColors.faint,
                      ),
                      const Spacer(),
                      Text(
                        a.title(s.isRu),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: on ? PlColors.text : PlColors.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.desc(s.isRu),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.25,
                          color: on ? PlColors.muted : PlColors.faint,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
