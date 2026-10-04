import 'package:flutter/material.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:provider/provider.dart';

/// Always-visible “where am I / what unlocks next” across all phases.
class JourneyMap extends StatelessWidget {
  const JourneyMap({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final stage = context.watch<DeskController>().journeyStage;
    return PathCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.jmTitle, style: pathCapStyle.copyWith(color: PlColors.accent)),
          const SizedBox(height: 10),
          for (var i = 0; i < 6; i++)
            _Row(
              title: s.jmStage(i),
              sub: s.jmUnlock(i),
              done: i < stage,
              current: i == stage,
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.sub, required this.done, required this.current});
  final String title;
  final String sub;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? PlColors.bull
        : current
            ? PlColors.accent
            : PlColors.faint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done
                ? Icons.check_circle_rounded
                : current
                    ? Icons.radio_button_checked_rounded
                    : Icons.lock_outline_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                    color: current ? PlColors.text : (done ? PathInk.body : PlColors.muted),
                  ),
                ),
                Text(sub, style: pathFineStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
