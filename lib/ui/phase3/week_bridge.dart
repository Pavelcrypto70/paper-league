import 'package:flutter/material.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:provider/provider.dart';

/// Phase 3: after 7 Daily Desks — explain League, tabs and desk buttons
/// before the free terminal opens.
class WeekBridge extends StatelessWidget {
  const WeekBridge({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    final step = desk.phase3Step.clamp(0, 3);

    final (title, body, child) = switch (step) {
      0 => (s.p3Title0, s.p3Body0, _WeekStats(desks: desk.habitDesksDone, copies: desk.move1Copies)),
      1 => (
          s.p3Title1,
          s.p3Body1,
          _Bullets(icon: Icons.military_tech_rounded, items: [s.p3LeaguePoint1, s.p3LeaguePoint2, s.p3LeaguePoint3]),
        ),
      2 => (
          s.p3Title2,
          '',
          _Tabs(items: [
            (Icons.show_chart_rounded, s.p3TabDesk),
            (Icons.layers_rounded, s.p3TabBook),
            (Icons.military_tech_rounded, s.p3TabLeague),
            (Icons.person_rounded, s.p3TabYou),
          ]),
        ),
      _ => (
          s.p3Title3,
          '',
          _Bullets(icon: Icons.touch_app_rounded, items: [s.p3BtnLong, s.p3BtnShort, s.p3BtnDesk]),
        ),
    };

    final last = step >= 3;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(s.p3Cap, style: pathCapStyle.copyWith(color: PlColors.bull)),
        const SizedBox(height: 4),
        Text(s.p3StepOf(step + 1), style: pathMono(size: 12, color: PlColors.muted)),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: AnimatedContainer(
                  duration: PlMotion.standard,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i < step
                        ? PlColors.bull
                        : i == step
                            ? PlColors.accent
                            : PlColors.surface3,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        Text(title, style: pathTitleStyle(context)),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(body, style: pathSubStyle),
        ],
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: PlMotion.emphasis,
          child: KeyedSubtree(key: ValueKey(step), child: child),
        ),
        const SizedBox(height: 20),
        PathButton(
          last ? s.p3ToLeague : s.p3Next,
          trailingIcon: Icons.arrow_forward_rounded,
          pulse: true,
          onPressed: () async {
            pathTap(strong: true);
            final d = context.read<DeskController>();
            if (last) {
              await d.completePhase3Bridge(goToTab: 2);
            } else {
              await d.advancePhase3();
            }
          },
        ),
      ],
    );
  }
}

class _WeekStats extends StatelessWidget {
  const _WeekStats({required this.desks, required this.copies});
  final int desks;
  final int copies;

  @override
  Widget build(BuildContext context) {
    return PathCard(
      accent: true,
      child: Row(
        children: [
          Expanded(child: _Stat(value: '$desks', label: 'Daily Desk', color: PlColors.accent)),
          Expanded(child: _Stat(value: '$copies', label: S.of(context).isRu ? 'копий' : 'copies', color: PlColors.bull)),
          const Expanded(child: _Stat(value: '100%', label: 'stop', color: PlColors.warn)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: pathMono(size: 26, weight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: pathCapStyle),
      ],
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.icon, required this.items});
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return PathCard(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: PlColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(items[i], style: const TextStyle(fontSize: 15, height: 1.4, color: PathInk.body)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.items});
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (icon, text) in items) ...[
          PathCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: PlColors.accentDim,
                    borderRadius: BorderRadius.circular(PlRadius.md),
                  ),
                  child: Icon(icon, size: 20, color: PlColors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: PathInk.body))),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
